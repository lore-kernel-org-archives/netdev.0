From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 03/27] Documentation/networking/igb.txt: update documentation
Date: Fri, 10 Dec 2010 21:25:59 -0800
Message-ID: <AANLkTimAZNyowHaZ_qUWEiTfr1qDDoZtb69JbxyBsUX_@mail.gmail.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291974667-30254-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291996224.11673.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, davem@davemleft.org, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38557 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab0LKF0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:26:00 -0500
Received: by iwn9 with SMTP id 9so6638717iwn.5
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 21:25:59 -0800 (PST)
In-Reply-To: <1291996224.11673.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 07:50, Ben Hutchings <bhutchings@solarflare.com=
> wrote:
> On Fri, 2010-12-10 at 01:50 -0800, Jeff Kirsher wrote:
>> Update Intel Wired LAN igb documentation.
>>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>> =C2=A0Documentation/networking/igb.txt | =C2=A0 22 +++++++++++++++++=
++---
>> =C2=A01 files changed, 19 insertions(+), 3 deletions(-)
>>
>> diff --git a/Documentation/networking/igb.txt b/Documentation/networ=
king/igb.txt
>> index ab2d718..393bdb7 100644
>> --- a/Documentation/networking/igb.txt
>> +++ b/Documentation/networking/igb.txt
>> @@ -36,6 +36,7 @@ Default Value: 0
>> =C2=A0This parameter adds support for SR-IOV. =C2=A0It causes the dr=
iver to spawn up to
>> =C2=A0max_vfs worth of virtual function.
>>
>> +
>> =C2=A0Additional Configurations
>> =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>
>> @@ -60,7 +61,8 @@ Additional Configurations
>> =C2=A0 =C2=A0Ethtool
>> =C2=A0 =C2=A0-------
>> =C2=A0 =C2=A0The driver utilizes the ethtool interface for driver co=
nfiguration and
>> - =C2=A0diagnostics, as well as displaying statistical information.
>> + =C2=A0diagnostics, as well as displaying statistical information. =
The latest
>> + =C2=A0version of Ethtool can be found at:
>>
>> =C2=A0 =C2=A0http://sourceforge.net/projects/gkernel.
>
> Please update this to:
> http://ftp.kernel.org/pub/software/network/ethtool/
>
>> @@ -103,8 +105,8 @@ Additional Configurations
>>
>> =C2=A0 =C2=A0NOTE: You need to have inet_lro enabled via either the =
CONFIG_INET_LRO or
>> =C2=A0 =C2=A0CONFIG_INET_LRO_MODULE kernel config option. Additional=
ly, if
>> - =C2=A0CONFIG_INET_LRO_MODULE is used, the inet_lro module needs to=
 be loaded
>> - =C2=A0before the igb driver.
>> + =C2=A0CONFIG_INET_LRO_MODULE is used, the inet_lro module needs to=
 be loaded before
>> + =C2=A0the igb driver.
>
> This should be removed as you don't use inet_lro any more.
>
>> =C2=A0 =C2=A0You can verify that the driver is using LRO by looking =
at these counters in
>> =C2=A0 =C2=A0Ethtool:
>> @@ -116,6 +118,20 @@ Additional Configurations
>>
>> =C2=A0 =C2=A0NOTE: IPv6 and UDP are not supported by LRO.
>>
>> + =C2=A0MAC and VLAN anti-spoofing feature
>> + =C2=A0----------------------------------
>> + =C2=A0When a malicious driver attempts to send a spoofed packet, i=
t is dropped by
>> + =C2=A0the hardware and not transmitted. =C2=A0An interrupt is sent=
 to the PF driver
>> + =C2=A0notifying it of the spoof attempt.
>> +
>> + =C2=A0When a spoofed packet is detected the PF driver will send th=
e following
>> + =C2=A0message to the system log (displayed by =C2=A0the "dmesg" co=
mmand):
>> +
>> + =C2=A0Spoof event(s) detected on VF(n)
>> +
>> + =C2=A0Where n=3Dthe VF that attempted to do the spoofing.
>
> I can't see that message in the PF driver code; does this actually ap=
ply
> to the in-tree driver? =C2=A0Also I hope this is rate-limited.
>
> Ben.
>

=46or once the documentation was ahead of the code... :) I will update
the patch, and I have updated the anti-spoofing patch we have in
testing to also update the documentation at the same time the code is
updated.

--=20
Cheers,
Jeff

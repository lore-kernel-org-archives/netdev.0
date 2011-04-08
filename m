From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-2.6] ixgbe: only enable WoL for magic packet by default
Date: Fri, 8 Apr 2011 11:13:07 -0700
Message-ID: <BANLkTiner9iMOF8Y333OxBPhySSu9AwG+g@mail.gmail.com>
References: <1302187315-16487-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, martin.wilck@ts.fujitsu.com,
	john.r.fastabend@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63249 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313Ab1DHSNb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 14:13:31 -0400
Received: by fxm17 with SMTP id 17so2497592fxm.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 11:13:30 -0700 (PDT)
In-Reply-To: <1302187315-16487-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 7, 2011 at 07:41, Andy Gospodarek <andy@greyhouse.net> wrot=
e:
> Martin Wilck <martin.wilck@ts.fujitsu.com> reported that systems usin=
g
> the ixgbe-driver that were capable of WoL were rebooting almost as so=
on
> as they were shut down. =C2=A0This is because the default WoL setting=
s
> enabled magic packet, broadcast, unicast, and multicast.
>
> Other Intel devices seem to use the stored eeprom value for initial W=
oL
> capabilities. =C2=A0The 82578DM (e1000e) and 82576 (igb) the devices =
I looked
> at had only the magic packet enabled in the eeprom, so that seems
> appropriate on ixgbe-based devices as well. =C2=A0I set the WoL optio=
ns on my
> 82578DM to be the same default as the ixgbe devices (umbg) and saw th=
e
> same as Martin -- almost as soon as my box shutdown, it booted again.
>
> This patch changes the default to only be the magic packet. =C2=A0Thi=
s is the
> same as the default for most Intel and non-Intel hardware currently
> upstream.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> CC: Martin Wilck <martin.wilck@ts.fujitsu.com>
>

Thanks Andy! I have added the patch to my queue.

--=20
Cheers,
Jeff

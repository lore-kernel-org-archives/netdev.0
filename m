From: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 13:13:54 -0500
Message-ID: <4DF25EE2.6020803@uth.tmc.edu>
References: <4DF0E638.2010506@uth.tmc.edu> <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu> <4DF24154.3060505@uth.tmc.edu> <1307722621.4044.17.camel@edumazet-laptop> <4DF248C5.9050004@uth.tmc.edu> <1307724870.4044.20.camel@edumazet-laptop> <4DF25BA2.4040200@uth.tmc.edu> <1307729054.2872.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.uth.tmc.edu ([129.106.148.58]:64815 "EHLO mta3.uth.tmc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854Ab1FJSNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 14:13:55 -0400
In-Reply-To: <1307729054.2872.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2011 01:04 PM, Eric Dumazet wrote:
> Le vendredi 10 juin 2011 =C3=A0 13:00 -0500, Charles Bearden a =C3=A9=
crit :
>
>> Each keepalive from the Win2008 machine has a 1-byte payload 0x00. T=
he last byte
>> of the last packet with a payload before that from the Win2008 host =
(at
>> 14:40:18.166394 in the paste) is also 0x00. Is that what you were as=
king about?
>>
>
> Yes, thats fine, thanks :)

One other thing: when tcp timestamps are disabled on the Linux (receivi=
ng) end,=20
so that the Win2008 host sends keepalives without timestamps, the check=
sums in=20
the keepalives are correct. It's only when the keepalives also contain=20
timestamps that the checksums are broken.

If you think this might be a Linux kernel issue, I'll be glad to keep w=
orking=20
with you, but I don't want to spam this list if my problem isn't releva=
nt. Thank=20
you for your help in any case.

Chuck

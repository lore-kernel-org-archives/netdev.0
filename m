From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Mon, 28 Mar 2011 12:36:26 -0700
Message-ID: <m1ei5rghqd.fsf@fess.ebiederm.org>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
	<1300743744.2837.7.camel@edumazet-laptop>
	<m1hbawi15z.fsf@fess.ebiederm.org>
	<20110327.180922.59673799.davem@davemloft.net>
	<1301340048.2506.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com, arnd@arndb.de, kaber@trash.net,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38067 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab1C1Tgf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 15:36:35 -0400
In-Reply-To: <1301340048.2506.13.camel@edumazet-laptop> (Eric Dumazet's
	message of "Mon, 28 Mar 2011 21:20:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9cri=
t :
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Mon, 21 Mar 2011 15:00:56 -0700
>>=20
>> > Eric Dumazet <eric.dumazet@gmail.com> writes:
>> >=20
>> >> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>> >> discussion ?
>> >=20
>> > No.  It seems I missed it, but I do have the same problem, and
>> > essentially the same fix.=20
>>=20
>> Can someone work on getting this straightened out and resubmit the
>> final patch so I can apply something?
>>=20
>
> Apparently Daniel is busy.
>
> I guess we can use Eric B. patch, then ?

That sounds good to me.

After reviewing the other thread to the best of my knowledge there are
no issues with the patch I submitted.  At worst I am 4 bytes extra
permissive about the mtu because of the way that path handles vlan
headers and that isn't something my patch changed.

Eric



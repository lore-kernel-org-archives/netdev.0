From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Sun, 02 Jun 2013 12:19:49 +0200
Message-ID: <87k3mcizlm.fsf@nemi.mork.no>
References: <87zjx9pf13.fsf@nemi.mork.no>
	<1365431422.3887.10.camel@edumazet-glaptop>
	<87li8tyrzs.fsf@nemi.mork.no>
	<1365434301.3887.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53401 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900Ab3FBKTy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 06:19:54 -0400
In-Reply-To: <1365434301.3887.14.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Mon, 08 Apr 2013 08:18:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Mon, 2013-04-08 at 17:14 +0200, Bj=C3=B8rn Mork wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> > On Mon, 2013-04-08 at 11:06 +0200, Bj=C3=B8rn Mork wrote:
>> >
>> >> Apr  8 10:58:09 nemi kernel: [152701.980799] TCP: snd_cwnd is nul=
, please report this bug.
>> >> Apr  8 10:58:33 nemi kernel: [152725.176151] iwlwifi 0000:03:00.0=
: fail to flush all tx fifo queues
>> >> Apr  8 10:58:33 nemi kernel: [152725.185713] wlan0: authenticate =
with 00:22:90:f9:23:a0
>> >> Apr  8 10:58:33 nemi kernel: [152725.185738] wlan0: capabilities/=
regulatory prevented using AP HT/VHT configuration, downgraded
>> >> Apr  8 10:58:33 nemi kernel: [152725.190150] wlan0: send auth to =
00:22:90:f9:23:a0 (try 1/3)
>> >> Apr  8 10:58:33 nemi kernel: [152725.199812] wlan0: authenticated
>> >> Apr  8 10:58:33 nemi kernel: [152725.200020] iwlwifi 0000:03:00.0=
 wlan0: disabling HT as WMM/QoS is not supported by the AP
>> >> Apr  8 10:58:33 nemi kernel: [152725.200027] iwlwifi 0000:03:00.0=
 wlan0: disabling VHT as WMM/QoS is not supported by the AP
>> >> Apr  8 10:58:33 nemi kernel: [152725.204033] wlan0: associate wit=
h 00:22:90:f9:23:a0 (try 1/3)
>> >> Apr  8 10:58:33 nemi kernel: [152725.207317] wlan0: RX AssocResp =
from 00:22:90:f9:23:a0 (capab=3D0x421 status=3D0 aid=3D12)
>> >> Apr  8 10:58:33 nemi kernel: [152725.210745] wlan0: associated
>> >>=20
>> >
>> > Same issue was reported by Dave Jones on iwlwifi few days ago and =
I sent
>> > following debugging patch, could you try it ?
>>=20
>> Will do. The patch only applied on top of net-next, so I assume that=
's
>> what you want me to test it on?
>>=20
>> I looked through my logs and the 'fail to flush all tx fifo queues'
>> warning from iwlwifi appears very infrequent.  The last time before
>> today was March 18th...  Also accompanied by your warning.  That's t=
he
>> only two times I've seen that one. And I've been running v3.8-rc7 (w=
here
>> you introduced the warning) or newer since Feb 8th.
>>=20
>> So don't hold your breath.  This may take a few weeks to trigger aga=
in.
>
> I believe patch applies (with some fuzz) on Linus tree, and maybe on =
3.8
> too.

Just FYI, in case you wondered what happened here...

I've been running with the debug patch since you sent it to me, and
still is.  But the warning has not yet reappeared.

I'll continue using the patch for a while, but will eventually drop it
if the warning cannot be reproduced in another couple of weeks time.
There have been a few fixes to iwlwifi in the meantime, and I do not
rule out the possibility that some of these removed the triggering
event.


Thanks,
Bj=C3=B8rn

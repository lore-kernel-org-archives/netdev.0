From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Mon, 08 Apr 2013 08:18:21 -0700
Message-ID: <1365434301.3887.14.camel@edumazet-glaptop>
References: <87zjx9pf13.fsf@nemi.mork.no>
	 <1365431422.3887.10.camel@edumazet-glaptop> <87li8tyrzs.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:33447 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936005Ab3DHPSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:18:25 -0400
Received: by mail-oa0-f50.google.com with SMTP id n1so6360400oag.9
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 08:18:24 -0700 (PDT)
In-Reply-To: <87li8tyrzs.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 17:14 +0200, Bj=C3=B8rn Mork wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> > On Mon, 2013-04-08 at 11:06 +0200, Bj=C3=B8rn Mork wrote:
> >
> >> Apr  8 10:58:09 nemi kernel: [152701.980799] TCP: snd_cwnd is nul,=
 please report this bug.
> >> Apr  8 10:58:33 nemi kernel: [152725.176151] iwlwifi 0000:03:00.0:=
 fail to flush all tx fifo queues
> >> Apr  8 10:58:33 nemi kernel: [152725.185713] wlan0: authenticate w=
ith 00:22:90:f9:23:a0
> >> Apr  8 10:58:33 nemi kernel: [152725.185738] wlan0: capabilities/r=
egulatory prevented using AP HT/VHT configuration, downgraded
> >> Apr  8 10:58:33 nemi kernel: [152725.190150] wlan0: send auth to 0=
0:22:90:f9:23:a0 (try 1/3)
> >> Apr  8 10:58:33 nemi kernel: [152725.199812] wlan0: authenticated
> >> Apr  8 10:58:33 nemi kernel: [152725.200020] iwlwifi 0000:03:00.0 =
wlan0: disabling HT as WMM/QoS is not supported by the AP
> >> Apr  8 10:58:33 nemi kernel: [152725.200027] iwlwifi 0000:03:00.0 =
wlan0: disabling VHT as WMM/QoS is not supported by the AP
> >> Apr  8 10:58:33 nemi kernel: [152725.204033] wlan0: associate with=
 00:22:90:f9:23:a0 (try 1/3)
> >> Apr  8 10:58:33 nemi kernel: [152725.207317] wlan0: RX AssocResp f=
rom 00:22:90:f9:23:a0 (capab=3D0x421 status=3D0 aid=3D12)
> >> Apr  8 10:58:33 nemi kernel: [152725.210745] wlan0: associated
> >>=20
> >
> > Same issue was reported by Dave Jones on iwlwifi few days ago and I=
 sent
> > following debugging patch, could you try it ?
>=20
> Will do. The patch only applied on top of net-next, so I assume that'=
s
> what you want me to test it on?
>=20
> I looked through my logs and the 'fail to flush all tx fifo queues'
> warning from iwlwifi appears very infrequent.  The last time before
> today was March 18th...  Also accompanied by your warning.  That's th=
e
> only two times I've seen that one. And I've been running v3.8-rc7 (wh=
ere
> you introduced the warning) or newer since Feb 8th.
>=20
> So don't hold your breath.  This may take a few weeks to trigger agai=
n.
>=20

I believe patch applies (with some fuzz) on Linus tree, and maybe on 3.=
8
too.

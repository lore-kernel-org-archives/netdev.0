From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 16:22:37 +0200
Message-ID: <1271686957.3845.49.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	 <1271679244.3845.43.camel@edumazet-laptop>
	 <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	 <1271683627.3845.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:58833 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab0DSOWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 10:22:43 -0400
Received: by bwz25 with SMTP id 25so5647284bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 07:22:42 -0700 (PDT)
In-Reply-To: <1271683627.3845.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 15:27 +0200, Eric Dumazet a =C3=A9crit :

> This is not true Changli
>=20
> Please read again all previous mails about RPS, or the code.
>=20

Hmm, I just read again, and I now remember Tom used a single bitmap,
then we had to add a second set because of a possible race.

A list would be enough.




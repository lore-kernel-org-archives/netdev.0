From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 06:24:40 +0100
Message-ID: <1322025880.29324.1.camel@edumazet-laptop>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	 <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Young <jlyo@jlyo.org>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39474 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab1KWFYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:24:45 -0500
Received: by wwe5 with SMTP id 5so1619797wwe.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:24:44 -0800 (PST)
In-Reply-To: <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 21:06 -0500, John Heffner a =C3=A9crit=
 :
> Offhand, I'd guess you're overflowing the TCP SYN queue.  (You can tr=
y
> tuning tcp_max_syn_backlog.)
>=20

There is one litle thing called "netstat -s", a very useful tool,
included in many distros :)

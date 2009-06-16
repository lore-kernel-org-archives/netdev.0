From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: lots of cpu time spent in skb_copy_bits() in net-next with
	small mtu
Date: Tue, 16 Jun 2009 19:20:00 +0000
Message-ID: <1245180000.7150.6.camel@Maple>
References: <20090612161320.GB4290@neterion.com>
	 <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <ben.lahaise@neterion.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:50433 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbZFPTUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 15:20:02 -0400
Received: by pzk17 with SMTP id 17so2884645pzk.33
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 12:20:04 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-06-12 at 22:57 +0300, Ilpo J=C3=A4rvinen wrote:
> On Fri, 12 Jun 2009, Benjamin LaHaise wrote:
>=20
> > Just a heads up: something in net-next is resulting in lots of cpu =
time=20
> > being spent in skb_copy_bits() (called from tcp_collapse()) when an=
 ethernet=20
> > interface mtu is lowered to 576 on the source and dest machines run=
ning=20
> > netperf.  This behaviour does not appear in 2.6.29.  I'll try to bi=
sect=20
> > it this weekend.
>=20
> I'd suggest somebody goes through DaveM's abstraction patch 915219441=
d56=20
> (I'm totally out of time so somebody else has to do it if a timely=20
> solution is desired)... It was quite messy on those parts and I alrea=
dy=20
> found one issue from it (2df9001edc3) and wouldn't be too surprised i=
f=20
> there would be some more lurking around...=20

I couldn't find anything wrong with tcp_prune_queue() and its helpers a=
s
they appear in today's net-next.

Take that with a grain of salt if you wish--I'm going to go take a
couple grains of aspirin.

  --  John


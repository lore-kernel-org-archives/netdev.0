From: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Subject: Re: TCP fast retransmit
Date: Fri, 16 Dec 2011 16:53:45 +0100
Message-ID: <C0707EB4-E233-491E-8B05-7D0DACDE1C72@mpi-bpc.mpg.de>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
 <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com>
 <1323901909.2631.17.camel@edumazet-laptop>
 <201112150841.08087.carsten@wolffcarsten.de>
 <1323937469.2631.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:42792 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759643Ab1LPPxs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 10:53:48 -0500
Received: from gwdexc-fe12.exc.top.gwdg.de ([134.76.9.232] helo=smtp-exc.gwdg.de)
	by mailer.gwdg.de with esmtps (TLSv1:RC4-MD5:128)
	(Exim 4.72)
	(envelope-from <Ansgar.Esztermann@mpi-bpc.mpg.de>)
	id 1Rba4J-0001yN-Fq
	for netdev@vger.kernel.org; Fri, 16 Dec 2011 16:51:31 +0100
In-Reply-To: <1323937469.2631.31.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 15, 2011, at 9:24 , Eric Dumazet wrote:

> Really, my feeling is this trace is taken on receiver, and maybe LRO/=
GRO
> is buggy ?

Oh dear. I'm sorry, my mistake: in the beginning of a backup session, t=
he server transmits to the client, so this is indeed taken on the recei=
ver. I should have waited until the client begins to push data to the s=
erver, as that is where we've noticed the original problem of frequent =
RTOs.

I'll get a new trace extending all the way to the interesting part of t=
he session...


Sorry for the confusion,

A.

--=20
Ansgar Esztermann
DV-Systemadministration
Max-Planck-Institut f=FCr biophysikalische Chemie, Abteilung 105

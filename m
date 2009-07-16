From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Thu, 16 Jul 2009 13:01:19 +0200
Message-ID: <20090716110119.GA3100@ami.dom.local>
References: <20090708223459.GB3666@ami.dom.local> <4A5679CC.800@itcare.pl> <4A568444.7010307@itcare.pl> <20090710144754.GA25385@ami.dom.local> <20090711062455.GA3095@ami.dom.local> <4A5BC2B6.9020709@itcare.pl> <20090714162425.GA3090@ami.dom.local> <4A5E38EE.2090405@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:34275 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbZGPLB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 07:01:28 -0400
Received: by bwz28 with SMTP id 28so29648bwz.37
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 04:01:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A5E38EE.2090405@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2009 at 10:15:42PM +0200, Pawe=B3 Staszewski wrote:
=2E..
> With the same settings and 2.6.28 there was always cpu load from 1% t=
o 3%
> with gc_timeout =3D 15
=2E..
> So is there some patch or there will be patch that turn off definitel=
y =20
> route cache ?
>
>
> For now i use
> gc_timeout =3D 1  in my routers and all is working fine - there is on=
ly 1 =20
> second of 20% of cpu load after every 20 sec.

I guess, I misunderstood your intention; it looks like there are some
slowdowns in route cache handling vs. 2.6.28, which probably could be
partly tuned up with config parameters or fixed with some patch, but
it needs more testing/debugging, including additional data from 2.6.28
for comparison (I'm not sure if you're using this kernel yet).

But if you think turning off route cache works better for you (btw,
2.6.29.6 lacks at least 2 patches fixing this which 2.6.30.1 has) then
of course we can stop this thread, no problem.

Regards,
Jarek P.

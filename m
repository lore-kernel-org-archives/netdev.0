From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Fri, 14 Aug 2009 18:54:58 +0530
Message-ID: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>,
	herbert@gondor.apana.org.au
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:50990 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbZHNNY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 09:24:57 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7EDMTS8001597
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:22:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7EDOvrn471534
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:24:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7EDOuq7017504
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:24:56 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFHi Jarek,

Jarek Poplawski <jarkao2@gmail.com> wrote on 08/14/2009 04:31:27 PM:

> Alas, private or public, these values are lower on average than
> before, so I'm not sure the complexity (especially in reading) added
> by this patch is worth it. So, I can only say it looks formally OK,
> except the changelog and maybe 2 cosmetical suggestions below.

Maybe the different test parameters result in smaller improvements.
I agree with you - the first approach is very readable and probably
preferable, while the second introduces a new structure and more
complexity.

I am sending both these versions a last time, after fixing your
comments in case someone can help decide if one or the other is
better (sorry I forgot to run checkpatch couple of times, will try
to remember next time).

Thanks,

- KK

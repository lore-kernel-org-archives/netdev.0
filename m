From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] fragment locally-generated IPsec6 packets that need it
Date: Tue, 14 Dec 2010 09:56:55 -0800
Message-ID: <OF654C33B6.C8B004C1-ON882577F9.006284A3-882577F9.00629828@us.ibm.com>
References: <1292271571.8593.9.camel@w-dls.beaverton.ibm.com> <20101214010929.GA10354@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45515 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755109Ab0LNR47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 12:56:59 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBEHmDht003830
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:48:42 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 92EEC4DE803E
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:54:52 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBEHuu5l145910
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:56:57 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBEHuuWx015959
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 10:56:56 -0700
In-Reply-To: <20101214010929.GA10354@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/13/2010 05:09:29 PM:

> > +EXPORT_SYMBOL_GPL(ip6_fragment);
> 
> There is no need to export this as xfrm6_output.c is always part
> of ipv6.o.

Herbert, thanks! I'll remove it and repost.

                                        +-DLS


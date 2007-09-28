From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Fri, 28 Sep 2007 18:31:50 +0200
Message-ID: <46FD2C76.5090402@trash.net>
References: <20070927132037.GA17056@gondor.apana.org.au>	<20070927132941.GB25353@2ka.mipt.ru>	<46FBB296.8020901@trash.net> <20070927.125239.129764503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55993 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbXI1Qbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:31:52 -0400
In-Reply-To: <20070927.125239.129764503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I still think the nf_*() prefixes should all go and the extern
> prototypes should go into an independant header file.
> 
> These are not netfilter routines, they are "INET" helpers.


Agreed. Evgeniy, can you send a new patch for this?

> And we should make similar treatment for all of the ipv6
> packet parser helper functions that ipv6 netfilter needs.


I'll look into that.


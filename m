From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: UDP path MTU discovery
Date: Thu, 1 Apr 2010 01:51:49 +0200
Message-ID: <20100331235149.GE3042@nuttenaction>
References: <1269561751.2891.8.camel@ilion>
 <4BAC0577.7070803@hp.com>
 <20100325.202636.149498207.davem@davemloft.net>
 <1270078923.2389.31.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:56604 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756351Ab0CaX7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 19:59:50 -0400
Content-Disposition: inline
In-Reply-To: <1270078923.2389.31.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Glen Turner | 2010-04-01 10:12:03 [+1030]:

>Does select() return from its blocking so the application can make
>use of this indication immediately, rather than after the
>application's exponentially-increasing wait?

Yes, poll() will return immediately with POLLERR.

>Is an incoming ICMP the only cause of EMSGSIZE?  That is, can an
>application safely retransmit immediately?

IIRC, yes.


Cheers, Hagen

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22

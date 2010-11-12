From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: can-bcm: fix minor heap overflow
Date: Thu, 11 Nov 2010 21:43:58 -0500
Message-ID: <1289529838.3090.209.camel@Dan>
References: <4CDB1856.4040001@hartkopp.net>
	 <20101112023950.GA8145@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Urs Thuermann <urs@isnogud.escape.de>, security@kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:61810 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab0KLCn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 21:43:59 -0500
In-Reply-To: <20101112023950.GA8145@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> If the string may be up to 17 bytes long why are you allocating 20?
> 

In Oliver's defense, this doesn't matter even a little bit.  The
structure will be allocated with kmalloc-1024 either way.

-Dan


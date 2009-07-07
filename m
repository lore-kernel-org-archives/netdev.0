From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
 in transport mode
Date: Mon, 06 Jul 2009 18:54:11 -0700 (PDT)
Message-ID: <20090706.185411.136676235.davem@davemloft.net>
References: <20090630140835.GA20811@gondor.apana.org.au>
	<20090706.183029.82831402.davem@davemloft.net>
	<20090707014008.GA27100@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe@saout.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753356AbZGGByE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:54:04 -0400
In-Reply-To: <20090707014008.GA27100@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 7 Jul 2009 09:40:08 +0800

> Hmm I deliberately didn't want to have this as the default because
> I want whoever that enables it to think about the implications.
> Having it on by default means that people will just set this up
> without realising that they're leaving the packet unprotected by
> checksums for a fraction of the path.
> 
> As I explained, it's almost impossible to use this without leaving
> the packet unprotected at least in one direction.
> 
> Having said that I'm fine with turning this into a sysctl or some
> global setting that's easier to enable.

Hmmm, aren't we talking about packets which were protected by either a
hash, strong encryption, or both at some point?

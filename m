From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Thu, 27 May 2010 10:22:46 +0100
Message-ID: <20100527092246.GB15298@linux-mips.org>
References: <20100526102758.GA25914@gondor.apana.org.au>
 <20100526152019.GA11985@linux-mips.org>
 <20100526221601.GA3369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:50372 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428Ab0E0JXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 05:23:01 -0400
Content-Disposition: inline
In-Reply-To: <20100526221601.GA3369@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 08:16:01AM +1000, Herbert Xu wrote:

> > I tested this on top of a 2.6.34 release kernel and asked the user
> > experiencing the problem to re-test and the problem still persists.
> 
> OK, it looks like my patch doesn't work because the transport
> header isn't set on the forwarding path.  Here's an updated patch:

Still no improvment.  I've moved all the collected tcpdumps to
ftp://www.linux-ax25.org/pub/traces/ including a README file describing
contents.

  Ralf

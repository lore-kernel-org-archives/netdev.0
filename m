From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 09:41:59 -0500
Message-ID: <1151505719.14895.43.camel@stevo-desktop>
References: <20060628033708.GA4922@gondor.apana.org.au>
	 <44A20311.5050301@pobox.com> <20060628042959.GA5561@gondor.apana.org.au>
	 <20060627.214323.92582051.davem@davemloft.net>
	 <20060628053554.GA5928@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:48676 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932468AbWF1OmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 10:42:01 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060628053554.GA5928@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 15:35 +1000, Herbert Xu wrote:
> On Tue, Jun 27, 2006 at 09:43:23PM -0700, David Miller wrote:
> > 
> > Socket state, and that is one thing I don't see them doing yet.
> 
> I wonder what happens when the Linux TCP stack attempts to open a
> connection to a remote host when that connection is already open
> in the RDMA NIC?  For that matter what happens if a Linux application
> decides to listen on a TCP port already listened on by the RDMA
> NIC?
> 
> The only saving grace is that they're only doing RDMA rather than
> arbitrary TCP.  However, exactly the same infrastructure can be used
> to do arbitrary TCP should they wish to.
>  
> > But we have to realize they've already been given %95 of the
> > interfaces they need to speak IP using our routes and our neighbour
> > entries.
> > 
> > Right?
> 
> Yes, however I think the same argument could be applied to TOE.
> 
> With their RDMA NIC, we'll have TCP/SCTP connections that bypass
> netfilter, tc, IPsec, AF_PACKET/tcpdump and the rest of our stack
> while at the same time it is using the same IP address as us and
> deciding what packets we will or won't see.
> 

Doesn't iSCSI have the same issue?  No netfilter, IPsec, tcpdump, etc...





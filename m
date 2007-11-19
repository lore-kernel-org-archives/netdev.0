From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
	filter
Date: Mon, 19 Nov 2007 09:49:36 -0200
Message-ID: <20071119114936.GE14882@ghostprotocols.net>
References: <p73bq9tau2x.fsf@bingen.suse.de> <20071117.160926.232024605.davem@davemloft.net> <20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net> <20071119044117.GA1880@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbXKSLtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 06:49:55 -0500
Content-Disposition: inline
In-Reply-To: <20071119044117.GA1880@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Nov 19, 2007 at 12:41:17PM +0800, Herbert Xu escreveu:
> On Sun, Nov 18, 2007 at 02:40:10PM -0800, David Miller wrote:
> >
> > This can be fixed, the above cannot.
> 
> That's a good point.  Perhaps one way of getting that info to
> the user without putting it in UDPInDatagrams is to create an
> inet_diag interface for UDP and put the number of queued packets
> for each socket in it.

This is something I would love to see: UDP refactored so that it gets
its hash tables/lookup code more and more looking like what we have in
inet_hashtables (struct inet_hashinfo, etc) so that udp_diag would just
fit in the inet_diag infrastructure, like dccp, that is in some aspects
like TCP and in others like UDP and already uses this infrastructure.

- Arnaldo

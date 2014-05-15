From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Thu, 15 May 2014 09:31:22 +0100
Message-ID: <1400142682.30687.3.camel@kazak.uk.xensource.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>
	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53734F9F.2010101@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:35065 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbaEOIbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 04:31:46 -0400
In-Reply-To: <53734F9F.2010101@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 12:12 +0100, Zoltan Kiss wrote:
> > The 'cleanup' of stale ubufs should be right after __pskb_pull_tail().
> We can't fix every place in the kernel where frags might be changed, 
> especially with a netback specific stuff, so unfortunately that won't work

Is it worth fixing up the ones in netback though so that the things
injected into the stack are consistent when we hand them over? It would
avoid some search overhead on the rx path at the other end I guess?
Perhaps not significant though.

Ian.

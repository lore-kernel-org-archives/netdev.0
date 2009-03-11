From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for non-drops and modifying end-of-line points for skbs
Date: Thu, 12 Mar 2009 00:39:02 +0300
Message-ID: <20090311213902.GA18878@ioremap.net>
References: <20090303170307.GD1480@hmsreliant.think-freely.org> <20090305210105.GC12835@hmsreliant.think-freely.org> <20090311.091830.152269823.davem@davemloft.net> <49B7E827.3070203@cosmosbay.com> <20090311170701.GA17005@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:35991 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbZCKVjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 17:39:13 -0400
Content-Disposition: inline
In-Reply-To: <20090311170701.GA17005@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 01:07:01PM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> > I was wondering if packets droped at NIC level are handled by "Network Drop Monitor".
> > (See recent discussion about Multicast packet loss)
> > 
> > I believe not, maybe I missed something ...
> > 
> No, unfortunately, theres no really good way to detect drops at the driver level
> without polling them periodically, which I think is somewhat in opposition to the
> point of this utility.  I'd welcome suggestions however.

It could be possible to check softnet stats difference when napi is
scheduled or drop monitor is about to send a packet to the userspace
about different drop.

-- 
	Evgeniy Polyakov

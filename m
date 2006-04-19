From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RESEND][PATCH] ebtables: clean up vmalloc usage in
 net/bridge/netfilter/ebtables.c
Date: Wed, 19 Apr 2006 16:03:28 -0700 (PDT)
Message-ID: <20060419.160328.128989267.davem@davemloft.net>
References: <20060419065025.GE17192@random.pao.digeo.com>
	<20060419.154126.64036253.davem@davemloft.net>
	<20060419155925.7aae7d25.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchandra@digeo.com, bridge@osdl.org, bdschuym@pandora.be,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56232
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751318AbWDSXD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 19:03:29 -0400
To: akpm@osdl.org
In-Reply-To: <20060419155925.7aae7d25.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 19 Apr 2006 15:59:25 -0700

> "David S. Miller" <davem@davemloft.net> wrote:
> >
> > An earlier variant of your patch was applied already, included below.
> > You'll need to submit the newer parts relative to the current tree.
> 
> This is a similar-but-different patch.  It applies OK.
> 
> I reviewed it (mostly - it's somewhat non-trivial to do this) and queued it
> up and was planning on sending it to you for post-2.6.17.

It's at least fixing a few bugs, and the parts which are cleanups
undoubtedly should prevent bugs in the future, so I think we
should consider it for 2.6.17 right?

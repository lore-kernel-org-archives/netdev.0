From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 4/9] cxgb4vf: Add code to provision T4 PCI-E SR-IOV
 Virtual Functions with hardware resources
Date: Tue, 29 Jun 2010 09:51:29 +0900
Message-ID: <20100629005129.GK10073@verge.net.au>
References: <201006251511.46660.leedom@chelsio.com>
 <20100626133746.GB30133@verge.net.au>
 <201006280955.07352.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:39865 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab0F2Avc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 20:51:32 -0400
Content-Disposition: inline
In-Reply-To: <201006280955.07352.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 09:55:07AM -0700, Casey Leedom wrote:
> | From: Simon Horman <horms@verge.net.au>
> | Date: Saturday, June 26, 2010 06:37 am
> | 
> | I wonder if it would be cleaner to move the guts of the last hunk
> | into a function (e.g. adap_init_sriov()) and have that be a dummy
> | function in the case that CONFIG_PCI_IOV in the first hunk is not set.
> 
>   I have no objection to this.  I'd like to do minor tuning work like
> that as a follow on rather than respin the patch.  But, as I said in my
> submission, I'm not familiar with this process so if making changes like
> the above is required I'll definitely jump on it.  I don't know what
> issues are "critical show stoppers" and which ones are "nice to have"
> once things are in place.

I don't regard my suggestion as merge-critical.

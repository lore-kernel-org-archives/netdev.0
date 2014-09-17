From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Wed, 17 Sep 2014 08:56:40 -0400
Message-ID: <20140917125640.GA4213@localhost.localdomain>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
 <20140916101704.GA3792@hmsreliant.think-freely.org>
 <20140916.162923.605101746131407931.davem@davemloft.net>
 <20140917102701.GA5699@hmsreliant.think-freely.org>
 <alpine.LRH.2.11.1409171529350.26961@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, steffen@klassert.de,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48114 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbaIQM5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 08:57:01 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1409171529350.26961@adalberg.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 03:43:54PM +0300, mroos@linux.ee wrote:
> > Shit, you're right, sorry about that.  Its odd, I'm running it here, and its not 
> > causing problems, but thats obviously wrong.  Meelis, please add the above fix
> > to your test and confirm that it sovles the problem.  If you could keep the
> > previous patch in place too that would be great, as we should probably add the
> > dma error checking anyway.
> > 
> > 
> > [PATCH] 3c59x: Fix bad offset spec in skb_frag_dma_map
> 
> Tested 2 variants: only this patch (backported to old state) and both 
> patches together.
> 
> Both work fine.
> 
Thank you, Meelis.  Dave, I'll propose these patches officially in just a bit

sorry for the 
> -- 
> Meelis Roos (mroos@linux.ee)
> 

From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Trouble Shooting ipsec
Date: Tue, 8 Feb 2011 16:37:18 -0500
Message-ID: <20110208213718.GB7450@hmsreliant.think-freely.org>
References: <4D504563.5010802@earthlink.net>
 <20110208183527.GA7450@hmsreliant.think-freely.org>
 <4D519A7D.5010405@earthlink.net>
 <20110208.113708.226773767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sclark46@earthlink.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38196 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab1BHVhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 16:37:24 -0500
Content-Disposition: inline
In-Reply-To: <20110208.113708.226773767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 08, 2011 at 11:37:08AM -0800, David Miller wrote:
> From: Stephen Clark <sclark46@earthlink.net>
> Date: Tue, 08 Feb 2011 14:33:17 -0500
> 
> > I'll continue investigating. It just so frustrating when the ipsec
> > packets just get dropped and you have no idea why. I wish there were
> > some hooks in the kernel so you could at least get some debug
> > information about what is happening.
> 
> There is a tracepoint (which you can monitor using perf) which tracks
> all packet drops.
> 
+1, you can also use dropwatch to monitor that tracepoint if the drop volume is
high.  
Neil


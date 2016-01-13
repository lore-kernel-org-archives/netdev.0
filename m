From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] 3c59x: Fix dma map/unmap imbalances
Date: Wed, 13 Jan 2016 15:12:12 -0500
Message-ID: <20160113201212.GA17915@hmsreliant.think-freely.org>
References: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
 <20160113.145558.283872959731839457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35300 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbcAMUMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 15:12:23 -0500
Content-Disposition: inline
In-Reply-To: <20160113.145558.283872959731839457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 02:55:58PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 13 Jan 2016 12:43:52 -0500
> 
> > Hey all-
> > 	recent enhancements to libdma revealed a few minor bugs in 3c59x, in
> > which dma ranges were mapped as singles and unmaped as pages, or vice versa.
> > These patches fix those up.  Tested by myself with success
> 
> Series applied, but there was trailing whitespace added in the second
> patch which I had to fix up by hand.
> 
> Please be careful when copy&pasteing stuff. :)
> 

Yeah, apologies, linville just pointed that out to me too.  This got reported on
RHEL6 which I think has an old whitespacing style, and I think I missed some
corrections that I should have made when I cherry picked it into an upstream
kernel.  Sorry, I'll be more careful in the future.

Best
Neil

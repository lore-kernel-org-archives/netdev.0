From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] phylib: add context argument to adjust link callback
Date: Fri, 6 Jul 2012 23:39:09 +0100
Message-ID: <1341614349.2923.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341605382-20563-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
To: <s-paulraj@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30629 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751278Ab2GFWjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:39:13 -0400
In-Reply-To: <1341605382-20563-1-git-send-email-s-paulraj@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 16:09 -0400, s-paulraj@ti.com wrote:
> From: Sandeep Paulraj <s-paulraj@ti.com>
> 
> This patch introduces a context argument for the adjust link callback.  This
> context information is set at phy_connect() (and its variants), and is passed
> back into the adjust_link callbacks on link state change events.
> 
> Such context information is necessary when a network device has multiple
> underlying ports.  Specifically, this comes into play when the netdev is
> really one of the ports going into an on-chip switch of some sort.
[...]

I have no particular opinion on the interface change, but the tree
should be compilable after each commit.  So patches 2-4 need to be
squashed together or otherwise refactored so that this is true.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

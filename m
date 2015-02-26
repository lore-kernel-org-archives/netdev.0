From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix link notification skb size
 calculation to include vlan ranges
Date: Thu, 26 Feb 2015 11:26:06 -0500 (EST)
Message-ID: <20150226.112606.1708529369110032286.davem@davemloft.net>
References: <1424937340-22115-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, sfeldma@gmail.com, wkok@cumulusnetworks.com,
	siva.mannem.lnx@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbbBZQ0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:26:08 -0500
In-Reply-To: <1424937340-22115-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Wed, 25 Feb 2015 23:55:40 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> my previous patch skipped vlan range optimizations during skb size
> calculations for simplicity.
> 
> This incremental patch considers vlan ranges during
> skb size calculations. This leads to a bit of code duplication
> in the fill and size calculation functions. But, I could not find a
> prettier way to do this. will take any suggestions.
> 
> Previously, I had reused the existing br_get_link_af_size size calculation
> function to calculate skb size for notifications. Reusing it this time
> around creates some change in behaviour issues for the usual
> .get_link_af_size callback.
> 
> This patch adds a new br_get_link_af_size_filtered() function to
> base the size calculation on the incoming filter flag and include
> vlan ranges.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks for following up on this.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove unused 'dev' argument from
 netif_needs_gso()
Date: Fri, 17 Apr 2015 13:29:09 -0400 (EDT)
Message-ID: <20150417.132909.1859863736464111217.davem@davemloft.net>
References: <1429278304-22260-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jesse@nicira.com,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbbDQR3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:29:11 -0400
In-Reply-To: <1429278304-22260-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 17 Apr 2015 15:45:04 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In commit 04ffcb255f22 ("net: Add ndo_gso_check") Tom originally
> added the 'dev' argument to be able to call ndo_gso_check().
> 
> Then later, when generalizing this in commit 5f35227ea34b
> ("net: Generalize ndo_gso_check to ndo_features_check")
> Jesse removed the call to ndo_gso_check() in netif_needs_gso()
> by calling the new ndo_features_check() in a different place.
> This made the 'dev' argument unused.
> 
> Remove the unused argument and go back to the code as before.
> 
> Cc: Tom Herbert <therbert@google.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.

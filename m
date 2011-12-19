From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Make the RSS indir tbl admin configurable
Date: Mon, 19 Dec 2011 15:51:14 -0500 (EST)
Message-ID: <20111219.155114.282504808309776049.davem@davemloft.net>
References: <1324078403-10617-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab1LSUvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:51:16 -0500
In-Reply-To: <1324078403-10617-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 16 Dec 2011 15:33:23 -0800

> This patch adds the ethtool callbacks necessary to change the rss
> indirection table from userspace.  Should the number of interrupts
> change (e.g.  across a close / open call, or through a reset) and
> any one of the indirection table values fall out-of-range, the driver
> will reset the indirection table to a default layout.
> 
> [Integrated many suggestions made by Ben Hutchings.]
> 
> Changes since v3
> 
> * Removed TG3_FLAG_SUPPORT_MSIX checks at the start of
>   tg3_get_rxfh_indir() and tg3_set_rxfh_indir().
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_trim explicitely check the linearity instead
 of data_len
Date: Sun, 22 May 2011 21:02:17 -0400 (EDT)
Message-ID: <20110522.210217.1746160427607139147.davem@davemloft.net>
References: <1306043169-26659-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: emmanuel.grumbach@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab1EWBCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:02:20 -0400
In-Reply-To: <1306043169-26659-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: emmanuel.grumbach@intel.com
Date: Sun, 22 May 2011 08:46:09 +0300

> From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> 
> The purpose of the check on data_len is to check linearity, so use the inline
> helper for this. No overhead and more explicit.
> 
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>

Applied.

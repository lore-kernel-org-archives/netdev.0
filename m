From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Wed, 11 Sep 2013 15:52:00 -0400 (EDT)
Message-ID: <20130911.155200.1385893449933655541.davem@davemloft.net>
References: <1378431145-7203-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757Ab3IKTwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 15:52:02 -0400
In-Reply-To: <1378431145-7203-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Fri,  6 Sep 2013 09:32:25 +0800

> When driver registration fails, we need to clean up the resources allocated
> before. cxgb4 missed to destroy the workqueue allocated at the very beginning.
> 
> This patch destroies the workqueue when registration fails.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

This patch was corrupted by your email client, please email the patch
to yourself, make sure the patch you receive in the email applies
cleanly to the current 'net' tree, and then resubmit.

Thanks.

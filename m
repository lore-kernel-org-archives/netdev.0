From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v4] 8139cp: Add dma_mapping_error checking
Date: Wed, 31 Jul 2013 17:02:19 -0700 (PDT)
Message-ID: <20130731.170219.7465642202004733.davem@davemloft.net>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
	<1375275836-22187-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab3HAACU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:02:20 -0400
In-Reply-To: <1375275836-22187-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 31 Jul 2013 09:03:56 -0400

> Self explanitory dma_mapping_error addition to the 8139 driver, based on this:
> https://bugzilla.redhat.com/show_bug.cgi?id=947250
> 
> It showed several backtraces arising for dma_map_* usage without checking the
> return code on the mapping.  Add the check and abort the rx/tx operation if its
> failed.  Untested as I have no hardware and the reporter has wandered off, but
> seems pretty straightforward.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks Neil.

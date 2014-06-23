From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: fix qnq mode detection on VFs
Date: Mon, 23 Jun 2014 14:47:07 -0700 (PDT)
Message-ID: <20140623.144707.29017823029772168.davem@davemloft.net>
References: <1403521889-8048-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbaFWVrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 17:47:08 -0400
In-Reply-To: <1403521889-8048-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 23 Jun 2014 16:41:29 +0530

> From: Suresh Reddy <suresh.reddy@emulex.com>
> 
> The driver (on PF or VF) needs to detect if the function is in qnq mode for
> a HW hack in be_rx_compl_get() to work.
> 
> The driver queries this information using the GET_PROFILE_CONFIG cmd
> (since the commit below can caused this regression.) But this cmd is not
> available on VFs and so the VFs fail to detect qnq mode. This causes
> vlan traffic to not work.
> 
> The fix is to use the the adapter->function_mode value queried via
> QUERY_FIRMWARE_CONFIG cmd on both PFs and VFs to detect the qnq mode.
> 
> Also QNQ_MODE was incorrectly named FLEX10_MODE; correcting that too as the
> fix reads much better with the name change.
> 
> Fixes: f93f160b5 ("refactor multi-channel config code for Skyhawk-R chip")
> 
> Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.

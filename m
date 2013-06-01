From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Force uninitialized state if
 FW_ON_ADAPTER is < FW_VERSION and we're the MASTER_PF
Date: Fri, 31 May 2013 17:27:32 -0700 (PDT)
Message-ID: <20130531.172732.1438540273906277034.davem@davemloft.net>
References: <1369920254-12122-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab3FAA1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:27:34 -0400
In-Reply-To: <1369920254-12122-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Thu, 30 May 2013 18:54:14 +0530

> From: Jay Hernandez <jay@chelsio.com>
> 
> Forcing uninitialized state allows us to upgrade and reinitialize the adapter.
> 
> FW_VERSION_T4 = 1.4.0.0
> FW_VERSION_T5 = 0.0.0.0
> At this point driver supports above and greater than above version of firmware.
> If it doesn't find the required firmware version than it forces the adapter to
> be reinitialized as shown below.
> 
> 1) If FW_ON_ADAPTER < FW_VERSION and we're the MASTER_PF force uninitialized
>    state and a FW upgrade if available.
> 
>        - If FW_ON_ADAPTER < /lib/firmware/cxgb4/t*fw.bin we will update the
>          adapters FW.
>        - If FW_ON_ADAPTER >= /lib/firmware/cxgb4/t*fw.bin don't upgrade FW.
>        - If upgrade_fw() fails force reinitialization of the adapter anyways,
>          it might still work.
> 
>    Either way forcing the uninitialized state allows cxgb4 reinitialize FW.
> 
> 2) If FW_ON_ADAPTER >= FW_VERSION driver follows normal path.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>

Applied.

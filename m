From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Force uninitialized state if FW in
 adapter is unsupported
Date: Fri, 28 Aug 2015 13:49:20 -0700 (PDT)
Message-ID: <20150828.134920.1789121714390550695.davem@davemloft.net>
References: <1440740832-11958-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbH1UtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:49:21 -0400
In-Reply-To: <1440740832-11958-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 28 Aug 2015 11:17:12 +0530

> Forcing uninitialized state allows us to upgrade and reinitialize
> the adapter.
> 
>     FW_VERSION_T4 = 1.4.0.0
>     FW_VERSION_T5 = 0.0.0.0
>     FW_VERSION_T6 = 0.0.0.0
> At this point driver supports above and greater than above version.
> 
> If FW in adapter < min FW_VERSION driver supports tries to upgrade the FW
> If FW in adapter >= FW_VERSION driver supports then it follows normal path
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.

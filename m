From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] Fixes T5 adapter init, due to incorrect FW
 version check
Date: Tue, 03 Dec 2013 17:00:20 -0500 (EST)
Message-ID: <20131203.170020.81119884094393685.davem@davemloft.net>
References: <1386070558-21521-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab3LCWAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:00:22 -0500
In-Reply-To: <1386070558-21521-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  3 Dec 2013 17:05:55 +0530

> This patch series fixes, Chelsio T5 adapter initialization failure due to
> incorrect firmware version check. This patch series modifies the firmware
> flashing mechanism for T4/T5 adapter.
> 
> The patch series moves chip type from struct adapter to struct adapter_params.
> It changes the references of chip type in cxgb4 and cxgb4vf drivers such that
> build failure is avoided.
> 
> Patch 3/3 is dependent on patch 1/3
> Patch 2/3 is also dependent on patch 1/3
> 
> We would like to request this patch series to get merged via David Miller's
> 'net' tree.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.

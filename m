From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: xgene: fix Tx flow control
Date: Thu, 17 Dec 2015 15:46:05 -0500 (EST)
Message-ID: <20151217.154605.1269611462220525072.davem@davemloft.net>
References: <1450333565-23670-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbLQUqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:46:07 -0500
In-Reply-To: <1450333565-23670-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Wed, 16 Dec 2015 22:26:05 -0800

> Currently the Tx flow control is based on reading the hardware state,
> which is not accurate since it may not reflect the descriptors that
> are not yet reached the memory.
> 
> To accurately control the Tx flow, changing it to be software based.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> ---
> 
> v2: Address v1 review comments
> 	- Removed use of atomic_t
> 	- Added tx_level and txc_level counters to pdata
> 
> v1: Initial version

Applied, thanks.

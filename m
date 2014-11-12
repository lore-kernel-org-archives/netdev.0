From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4 : dcb open-lldp interop fixes
Date: Wed, 12 Nov 2014 15:00:44 -0500 (EST)
Message-ID: <20141112.150044.1952363122549533770.davem@davemloft.net>
References: <1415777451-14144-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaKLUAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:00:47 -0500
In-Reply-To: <1415777451-14144-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 11 Nov 2014 23:30:51 -0800

> * In LLD_MANAGED mode, traffic classes were being returned in reverse order to
>   lldp agent.
> * Priotype of strict is no longer the default returned.
> * Change behaviour of getdcbx() based on discussions on lldp-devel
> 
> These were missed as there was no working fetch interface for open-lldp when
> running in LLD_MANAGED mode till now.
> 
> Fixes: 76bcb31efc06 ("cxgb4 : Add DCBx support codebase and dcbnl_ops")
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.

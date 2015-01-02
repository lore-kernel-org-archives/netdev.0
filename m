From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: free all rq buffs when allocation fails
Date: Fri, 02 Jan 2015 16:44:07 -0500 (EST)
Message-ID: <20150102.164407.1319629041737193981.davem@davemloft.net>
References: <1420212207-30219-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbABVoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:44:10 -0500
In-Reply-To: <1420212207-30219-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Fri,  2 Jan 2015 20:53:27 +0530

> When allocation of all RQs fail, we do not free previously allocated buffers,
> before returning error. This causes memory leak.
> 
> This patch fixes this by calling vnic_rq_clean(), which frees all the rq
> buffers.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Looks good, applied, thanks.

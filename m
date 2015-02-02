From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4: Remove preprocessor check for
 CONFIG_CXGB4_DCB
Date: Sun, 01 Feb 2015 22:37:56 -0800 (PST)
Message-ID: <20150201.223756.221672084158010157.davem@davemloft.net>
References: <1422587967-18405-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbBBGh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:37:57 -0500
In-Reply-To: <1422587967-18405-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 30 Jan 2015 08:49:27 +0530

> In commit dc9daab226aa ("cxgb4: Added support in debugfs to dump
> sge_qinfo") a preprocessor check for CONFIG_CXGB4_DCB got added, which should
> have been CONFIG_CHELSIO_T4_DCB. After adding the right preprocessor, build
> fails due to missing function ethqset2pinfo. Fixing that as well.
> 
> Reported-by: Paul Bolle <pebolle@tiscal.nl>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> 
> V2: Updated description since the patch also fixes build failure

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix incorrect sequence numbers shown in
 devlog
Date: Fri, 03 Jul 2015 09:54:15 -0700 (PDT)
Message-ID: <20150703.095415.1789048043199002196.davem@davemloft.net>
References: <1435920051-6756-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbbGCQyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:54:16 -0400
In-Reply-To: <1435920051-6756-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  3 Jul 2015 16:10:51 +0530

> Part of commit 49aa284fe64c4c1 ("cxgb4: Add support for devlog")
> change introduced a real bug where the Device Log Sequence Numbers are
> no longer being converted from firmware Big-Endian to local CPU-Endian
> format.
> 
> This patch moves all of the translation into the devlog_show() routine.
> The only endianness code now in devlog_open() is the small loop to find the
> earliest (lowest Sequence Number) Device Log entry in the circular buffer.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.

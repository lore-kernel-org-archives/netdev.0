From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt_en: Fix zero padding of tx push data.
Date: Tue, 23 Feb 2016 19:13:20 -0500 (EST)
Message-ID: <20160223.191320.257252668425313975.davem@davemloft.net>
References: <1456125026-16093-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcBXANg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 19:13:36 -0500
In-Reply-To: <1456125026-16093-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 22 Feb 2016 02:10:26 -0500

> The arithmetic to zero pad the last 64-bit word in the push buffer is not
> correct.
> 
> 1. It should be pdata + length to get to the end.
> 2. 'pdata' is void pointer and passing it to PTR_ALIGN() will cast the
> aligned pointer to void.  Pass 'end' which is u64 pointer to PTR_ALIGN()
> instead so that the aligned pointer - 1 is the last 64-bit pointer to data.
> 
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied, thanks Michael.

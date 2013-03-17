From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: add missing napi deletion in error path
Date: Sun, 17 Mar 2013 12:27:55 -0400 (EDT)
Message-ID: <20130317.122755.11365452165569890.davem@davemloft.net>
References: <1363361274-25754-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, meravs@broadcom.com, eilong@broadcom.com,
	dmitry@broadcom.com, yuvalmin@broadcom.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351Ab3CQQ15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:27:57 -0400
In-Reply-To: <1363361274-25754-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 15 Mar 2013 16:27:54 +0100

> If the hardware initialization fails in bnx2x_nic_load() after adding
> napi objects, they would not be deleted. A subsequent attempt to unload
> the bnx2x module detects a corruption in the napi list.
> 
> Add the missing napi deletion to the error path.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks.

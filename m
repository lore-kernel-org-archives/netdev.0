From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dcbnl : Fix misleading dcb_app->priority
 explanation
Date: Wed, 30 Jul 2014 17:21:20 -0700 (PDT)
Message-ID: <20140730.172120.1421252308196772240.davem@davemloft.net>
References: <1406606227-22776-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009AbaGaAVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 20:21:22 -0400
In-Reply-To: <1406606227-22776-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Mon, 28 Jul 2014 20:57:07 -0700

> Current explanation of dcb_app->priority is wrong. It says priority is
> expected to be a 3-bit unsigned integer which is only true when working with
> DCBx-IEEE. Use of dcb_app->priority by DCBx-CEE expects it to be 802.1p user
> priority bitmap. Updated accordingly
> 
> This affects the cxgb4 driver, but I will post those changes as part of a
> larger changeset shortly.
> 
> Fixes: 3e29027af4372 ("dcbnl: add support for ieee8021Qaz attributes")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Prevent NULL pointer dereference in kdump
Date: Thu, 25 Apr 2013 04:02:05 -0400 (EDT)
Message-ID: <20130425.040205.1470520940896024864.davem@davemloft.net>
References: <1366635183-9541-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab3DYICH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:02:07 -0400
In-Reply-To: <1366635183-9541-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 22 Apr 2013 15:53:03 +0300

> After verifying that by re-arranging the order by which interrupts' resource
> were allocated and requested, we could no longer re-produce the Spurious
> interrupt issue, we've dropped the spurious flag.

I told you :-)

Applied, thanks.

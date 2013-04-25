From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x, bnx2fc: Use per port max exchange
 resources
Date: Thu, 25 Apr 2013 04:07:13 -0400 (EDT)
Message-ID: <20130425.040713.242135751359124550.davem@davemloft.net>
References: <1366694550-2894-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bprakash@broadcom.com, mchan@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3DYIHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:07:19 -0400
In-Reply-To: <1366694550-2894-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 23 Apr 2013 08:22:30 +0300

> From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> 
> The firmware supports a maximum of 4K FCoE exchanges. In 4-port devices,
> or when working in multi-function mode, this resource needs to be distributed
> between the various possible FCoE functions.
> 
> This information needs to be calculated by bnx2x and propagated into bnx2fc
> via cnic. bnx2fc can then use this value to calculate corresponding xid
> resources instead of using global constants.
> 
> Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>

Applied, thanks.

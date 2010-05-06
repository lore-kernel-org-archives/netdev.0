From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] netdev: octeon_mgmt: Use proper MAC addresses.
Date: Thu, 06 May 2010 00:18:43 -0700 (PDT)
Message-ID: <20100506.001843.229750901.davem@davemloft.net>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
	<1273100593-11043-2-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754647Ab0EFHSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:18:36 -0400
In-Reply-To: <1273100593-11043-2-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  5 May 2010 16:03:08 -0700

> The original implementation incorrectly uses netdev->dev_addrs.
> 
> Use netdev->uc instead.  Also use netdev_for_each_uc_addr to iterate
> over the addresses.  Fix comment.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied.

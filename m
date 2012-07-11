From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] qlge: fix endian issue
Date: Wed, 11 Jul 2012 01:31:53 -0700 (PDT)
Message-ID: <20120711.013153.2184127223185969704.davem@davemloft.net>
References: <1341907362-17752-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215Ab2GKIbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:31:53 -0400
In-Reply-To: <1341907362-17752-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 10 Jul 2012 16:02:42 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> commit 6d29b1ef introduces a bug, ntohs is __be16_to_cpu,
> not cpu_to_be16.
> 
> We always use htons on IP_OFFSET and IP_MF, then compare
> with network package.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.

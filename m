From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: Don't deschedule NAPI when
 carrier off
Date: Fri, 08 Aug 2014 10:29:31 -0700 (PDT)
Message-ID: <20140808.102931.1051613105167978317.davem@davemloft.net>
References: <1407494580-19404-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHHR3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 13:29:33 -0400
In-Reply-To: <1407494580-19404-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Fri, 8 Aug 2014 11:43:00 +0100

> +	if (unlikely(queue->vif->disabled )) {
                                         ^^

Please get rid of that space and resubmit this patch, thank you.

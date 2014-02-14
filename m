From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: fix the potential NULL pointer in
 xmit_skb()
Date: Fri, 14 Feb 2014 00:12:52 -0500 (EST)
Message-ID: <20140214.001252.1994875881466995036.davem@davemloft.net>
References: <1392350408-3811-1-git-send-email-wuzhy@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wuzhy@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaBNFMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 00:12:53 -0500
In-Reply-To: <1392350408-3811-1-git-send-email-wuzhy@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Date: Fri, 14 Feb 2014 12:00:08 +0800

> The pointer hdr isn't assigned before hdr->mhdr and hdr->hdr
> are used, so it could be one invalid pointer.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

sizeof(x) does not evaluate any dereferences made by 'x'

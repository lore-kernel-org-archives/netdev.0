From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: fix a out of bounds access in __vxlan_find_mac
Date: Fri, 29 Jan 2016 20:11:44 -0800 (PST)
Message-ID: <20160129.201144.2002457013436459065.davem@davemloft.net>
References: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcA3ELq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:11:46 -0500
In-Reply-To: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 29 Jan 2016 09:43:47 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The size of all_zeros_mac is 6 byte, but eth_hash() will access the
> 8 byte, and KASan reported the below bug:
 ...
> it can be fixed by enlarging the all_zeros_mac to 8 byte, although it is
> harmless; eth_hash() will be called in other place with the memory which
> is larger and equal to 8 byte.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.

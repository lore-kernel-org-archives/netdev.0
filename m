From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel][PATCH net-next] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Tue, 14 Jan 2014 15:28:25 -0800 (PST)
Message-ID: <20140114.152825.2110618560908841742.davem@davemloft.net>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com
To: Annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaANX21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:28:27 -0500
In-Reply-To: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <Annie.li@oracle.com>
Date: Fri, 10 Jan 2014 06:48:38 +0800

> Current netfront only grants pages for grant copy, not for grant transfer, so
> remove corresponding transfer code and add receiving copy code in
> xennet_release_rx_bufs.
> 
> Signed-off-by: Annie Li <Annie.li@oracle.com>

If a Xen networking driver would review this I'd appreciate it.

Thanks.

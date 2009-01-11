From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_dma: acquire/release dma channels on ifup/ifdown
Date: Sun, 11 Jan 2009 00:20:46 -0800 (PST)
Message-ID: <20090111.002046.197779234.davem@davemloft.net>
References: <20090109235752.16379.98359.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maciej.sosnowski@intel.com
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751603AbZAKIUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:20:46 -0500
In-Reply-To: <20090109235752.16379.98359.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Jan 2009 16:57:53 -0700

> The recent dmaengine rework removed the capability to remove dma device
> driver modules while net_dma is active.  Rather than notify
> dmaengine-clients that channels are trying to be removed, we now rely on
> clients to notify dmaengine when they no longer have a need for
> channels.  Teach net_dma to release channels by taking dmaengine
> references at netdevice open and dropping references at netdevice close.
> 
> Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Applied, thanks!

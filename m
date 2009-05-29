From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 2/2] cxgb3: link fault fixes
Date: Fri, 29 May 2009 01:56:52 -0700 (PDT)
Message-ID: <20090529.015652.89167404.davem@davemloft.net>
References: <20090528212308.28184.39504.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757528AbZE2I4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:56:52 -0400
In-Reply-To: <20090528212308.28184.39504.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 28 May 2009 14:23:08 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Do not call t3_link_fault() under spinlock, as it calls msleep().
> Besides, only the access to pi->link_fault needs to be serialized.
> 
> Also initialize local variables before checking the link status,
> link state fields might otherwise end up containing garbage.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.

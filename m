From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/net/cxgb3/cxgb3_main.c: prevent reading
 uninitialized stack memory
Date: Thu, 16 Sep 2010 21:55:47 -0700 (PDT)
Message-ID: <20100916.215547.170109869.davem@davemloft.net>
References: <1284586992.6275.93.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753521Ab0IQEz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 00:55:29 -0400
In-Reply-To: <1284586992.6275.93.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 15 Sep 2010 17:43:12 -0400

> Fixed formatting (tabs and line breaks).
> 
> The CHELSIO_GET_QSET_NUM device ioctl allows unprivileged users to read
> 4 bytes of uninitialized stack memory, because the "addr" member of the
> ch_reg struct declared on the stack in cxgb_extension_ioctl() is not
> altered or zeroed before being copied back to the user.  This patch
> takes care of it.
> 
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next]hysdn: Kill directly reference of netdev->priv
Date: Wed, 03 Dec 2008 15:49:14 -0800 (PST)
Message-ID: <20081203.154914.134137743.davem@davemloft.net>
References: <4933F47A.5060104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbYLCXtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:49:14 -0500
In-Reply-To: <4933F47A.5060104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 01 Dec 2008 22:28:10 +0800

> Usually, netdev->priv should point to the memory of private
> data which is allocated in alloc_netdev().
> netdev_priv() is used to get the address of the private data.
> 
> Change the netdev->priv pointer to another memory is wrong.
> Use netdev->ml_priv for this case.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

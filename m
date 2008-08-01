From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Fri, 01 Aug 2008 04:05:18 -0700 (PDT)
Message-ID: <20080801.040518.93393560.davem@davemloft.net>
References: <4892E280.8050907@cn.fujitsu.com>
	<20080801.032424.114777556.davem@davemloft.net>
	<4892E6EC.3040201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752888AbYHALFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 07:05:18 -0400
In-Reply-To: <4892E6EC.3040201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 01 Aug 2008 18:35:24 +0800

> How about add a comment to netdev->priv
> 
> void	*priv;	/* pointer to private data, referent me by netdev_priv()*/

Sure, but I'd much rather apply a patch that converts
all the direct references :-)

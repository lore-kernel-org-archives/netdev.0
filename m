From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Tue, 05 Aug 2008 03:04:33 -0700 (PDT)
Message-ID: <20080805.030433.100665376.davem@davemloft.net>
References: <4892E6EC.3040201@cn.fujitsu.com>
	<20080801.040518.93393560.davem@davemloft.net>
	<4898238F.1050105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754243AbYHEKEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 06:04:32 -0400
In-Reply-To: <4898238F.1050105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 05 Aug 2008 17:55:27 +0800

> init_one() of cxgb2 makes several net_device to share one private data.
> For this purpose, direct reference is necessary.

It should use netdev->ml_priv which is created for this purpose.

Every direct netdev->priv usage is a bug.

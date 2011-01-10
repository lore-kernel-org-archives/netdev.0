From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] qlcnic: fix flash fw version read
Date: Mon, 10 Jan 2011 13:35:04 -0800 (PST)
Message-ID: <20110110.133504.209973144.davem@davemloft.net>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
	<1294654523-3085-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1AJVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:34:32 -0500
In-Reply-To: <1294654523-3085-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 10 Jan 2011 02:15:21 -0800

> Driver is reading flash fw version from defined address, this address
> may be invalid. Indeed Driver should read address for fw version through
> flash layout table. Flash layout table has defined region and address for
> fw version address should be read from fw image region.
> 
> Driver has check for old firmware, this bug can cause driver load fail.
> This patch will try to read fw version from flash image region, if that fails,
> read from defined address.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.

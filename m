From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rrunner: fix buffer overflow
Date: Sun, 03 Jan 2010 22:06:29 -0800 (PST)
Message-ID: <20100103.220629.71174384.davem@davemloft.net>
References: <20100102140846.GA5076@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753001Ab0ADGGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 01:06:25 -0500
In-Reply-To: <20100102140846.GA5076@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 2 Jan 2010 16:08:46 +0200

> tx_skbuff is define as:
>         struct sk_buff          *tx_skbuff[TX_RING_ENTRIES];
> 
> EVT_RING_ENTRIES is 64 and TX_RING_ENTRIES is 32.
> 
> This function is in a error path so that's why it wasn't noticed.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.

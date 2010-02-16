From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] cxgb3: fix link flap
Date: Mon, 15 Feb 2010 21:53:13 -0800 (PST)
Message-ID: <20100215.215313.237151931.davem@davemloft.net>
References: <20100213194429.27297.99280.stgit@speedy5.asicdesigners.com>
	<20100213194435.27297.79287.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752483Ab0BPFw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:52:58 -0500
In-Reply-To: <20100213194435.27297.79287.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sat, 13 Feb 2010 11:44:35 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> The driver is expected to report that the link is up
> when the phy Rx signal is established and the mac
> has not detected a link fault.
> The code is however broken, the driver does not check the link fault
> status when the phy link status changes.
> The link fault status being checked within a short period of time,
> it leads to link up/link down events.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.

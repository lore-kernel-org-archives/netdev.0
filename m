From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] qlge: bugfix: Add missing rx buf clean index on
 early exit.
Date: Thu, 12 Feb 2009 16:39:22 -0800 (PST)
Message-ID: <20090212.163922.22406530.davem@davemloft.net>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
	<1234360717-32194-7-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758058AbZBMAj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:39:28 -0500
In-Reply-To: <1234360717-32194-7-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 11 Feb 2009 05:58:37 -0800

> The large receive buffer queue is not properly tracking the current
> index in the case where an early exit occurs.  This can happen when a
> page alloc or dma mapping fails.  If this occurs the queue will get
> out of sync and invalid indexes can be written to the hardware.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.

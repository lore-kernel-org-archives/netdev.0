From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling
 logic
Date: Thu, 21 Oct 2010 04:31:34 -0700 (PDT)
Message-ID: <20101021.043134.214226395.davem@davemloft.net>
References: <4CB8C824.7090800@windriver.com>
	<20101018105017.GA16326@hmsreliant.think-freely.org>
	<20101018214356.GA27204@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757573Ab0JULbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:31:12 -0400
In-Reply-To: <20101018214356.GA27204@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 18 Oct 2010 17:43:56 -0400

>>From 35b078621c4ca6e6f5a5aed80c34594e00f08c8e Mon Sep 17 00:00:00 2001
> From: Allan Stephens <allan.stephens@windriver.com>
> Date: Thu, 14 Oct 2010 16:09:23 -0400
> Subject: [PATCH] tipc: delete needless memset from bearer enabling.
> 
> Eliminates zeroing out of the new bearer structure at the start of
> activation, since it is already in that state.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.

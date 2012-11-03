From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp-repair: Handle zero-length data put in rcv
 queue
Date: Fri, 02 Nov 2012 22:02:11 -0400 (EDT)
Message-ID: <20121102.220211.734003528595209418.davem@davemloft.net>
References: <508E9B3D.1050505@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gmavrikas@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab2KCCCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 22:02:12 -0400
In-Reply-To: <508E9B3D.1050505@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 29 Oct 2012 19:05:33 +0400

> When sending data into a tcp socket in repair state we should check
> for the amount of data being 0 explicitly. Otherwise we'll have an skb 
> with seq == end_seq in rcv queue, but tcp doesn't expect this to happen
> (in particular a warn_on in tcp_recvmsg shoots).
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> Reported-by: Giorgos Mavrikas <gmavrikas@gmail.com>

Applied, thanks.

> From 8f70f4ea4f509a3772ee7eb5d9d5c2571a86652a Mon Sep 17 00:00:00 2001
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Mon, 29 Oct 2012 18:12:41 +0400
> Subject: [PATCH] fix for repair queue getback
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

What is this?

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: set priority of STP packets
Date: Mon, 11 Feb 2013 14:18:40 -0500 (EST)
Message-ID: <20130211.141840.1018332289184968428.davem@davemloft.net>
References: <20130211102222.37743b22@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758803Ab3BKTSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:18:43 -0500
In-Reply-To: <20130211102222.37743b22@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 11 Feb 2013 10:22:22 -0800

> Spanning Tree Protocol packets should have always been marked as
> control packets, this causes them to get queued in the high prirority
> FIFO. As Radia Perlman mentioned in her LCA talk, STP dies if bridge
> gets overloaded and can't communicate. This is a long-standing bug back
> to the first versions of Linux bridge.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable, thanks.

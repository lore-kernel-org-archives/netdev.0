From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eliminate refcounting in backlog queue
Date: Sun, 03 Aug 2008 21:30:09 -0700 (PDT)
Message-ID: <20080803.213009.103189993.davem@davemloft.net>
References: <20080725123212.393314a9@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbYHDEaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 00:30:08 -0400
In-Reply-To: <20080725123212.393314a9@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 25 Jul 2008 12:32:12 -0700

> Avoid the overhead of atomic increment/decrement on each received packet.
> This helps performance of non-NAPI devices (like loopback).
> Use cleanup function to walk queue on each cpu and clean out any
> left over packets.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied, thanks Stephen.

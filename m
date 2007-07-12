From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp probe wraparound handling and other changes
Date: Wed, 11 Jul 2007 19:44:02 -0700 (PDT)
Message-ID: <20070711.194402.32095330.davem@davemloft.net>
References: <20070711105115.43ae0530@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932415AbXGLCnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:43:39 -0400
In-Reply-To: <20070711105115.43ae0530@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 11 Jul 2007 10:51:15 -0700

> Switch from formatting messages in probe routine and copying with kfifo, 
> to using a small circular queue of information and formatting on read. 
> This avoids wraparound issues with kfifo, and saves one copy.
> 
> Also make sure to state correct license, rather than copying off some other
> driver I started with.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.

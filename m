From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Tue, 08 Jan 2008 15:00:38 -0800 (PST)
Message-ID: <20080108.150038.57735076.davem@davemloft.net>
References: <20080108122814.12005.qmail@science.horizon.com>
	<20080108131956.13905.qmail@science.horizon.com>
	<20080108213640.GC4450@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@horizon.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbYAHXAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:00:38 -0500
In-Reply-To: <20080108213640.GC4450@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 8 Jan 2008 22:36:40 +0100

> linux@horizon.com <linux@horizon.com> :
> > I take that back.  This patch does NOT fix the leak, at least if
> > ping: sendmsg: No buffer space available
> > is any indication...
> 
> Can you try the patch below ?

Same kind of bug as the RX side :-)  I bet this fixes his
problem...

From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] Avoid two divides in tcp_output.c
Date: Thu, 20 Dec 2007 21:40:17 -0800 (PST)
Message-ID: <20071220.214017.123924372.davem@davemloft.net>
References: <476B5064.5010302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbXLUFkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 00:40:18 -0500
In-Reply-To: <476B5064.5010302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 06:34:28 +0100

> Because 'free_space' variable in __tcp_select_window() is signed,
> expression (free_space / 2) forces compiler to emit an integer divide.
> 
> This can be changed to a plain right shift, less expensive.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.

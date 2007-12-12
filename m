From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: remove netif_running() check from
 myri10ge_poll()
Date: Wed, 12 Dec 2007 11:02:43 -0800 (PST)
Message-ID: <20071212.110243.202840959.davem@davemloft.net>
References: <47602AAA.8060204@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751096AbXLLTCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:02:43 -0500
In-Reply-To: <47602AAA.8060204@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 12 Dec 2007 13:38:34 -0500

> Remove the bogus netif_running() check from myri10ge_poll().
> 
> This eliminates any chance that myri10ge_poll() can trigger
> an oops by calling netif_rx_complete() and returning
> with work_done == budget.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

Acked-by: David S. Miller <davem@davemloft.net>

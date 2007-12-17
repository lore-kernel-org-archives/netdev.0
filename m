From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: remove netif_running() check from myri10ge_poll()
Date: Mon, 17 Dec 2007 18:19:37 -0500
Message-ID: <47670409.7040803@garzik.org>
References: <47602AAA.8060204@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48960 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761981AbXLQXTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:19:41 -0500
In-Reply-To: <47602AAA.8060204@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin wrote:
> Remove the bogus netif_running() check from myri10ge_poll().
> 
> This eliminates any chance that myri10ge_poll() can trigger
> an oops by calling netif_rx_complete() and returning
> with work_done == budget.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

holding onto this patch but not applying, because NAPI discussions 
appear to be continuing...



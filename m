From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]: remove netif_running() check from
 myri10ge_poll()
Date: Thu, 20 Dec 2007 16:05:18 -0800
Message-ID: <20071220160518.fa65ac90.akpm@linux-foundation.org>
References: <47602AAA.8060204@myri.com>
	<20071212.110243.202840959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37360 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759864AbXLUAGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 19:06:04 -0500
In-Reply-To: <20071212.110243.202840959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 11:02:43 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Gallatin <gallatin@myri.com>
> Date: Wed, 12 Dec 2007 13:38:34 -0500
> 
> > Remove the bogus netif_running() check from myri10ge_poll().
> > 
> > This eliminates any chance that myri10ge_poll() can trigger
> > an oops by calling netif_rx_complete() and returning
> > with work_done == budget.
> > 
> > Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

hm, eight days old, fixes a possible oops and hasn't been merged anywhere
yet?

I'll put it in my for-2.6.24-via-other-subsystem queue.

From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 10:45:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007104554.605e4d7d@pirandello>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007103332.688393e3@pirandello>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041007103332.688393e3@pirandello>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Oct 2004 at 10h10, Colin Leroy wrote:

Hi, 

> How stupid, I just added a printk at the beginning of netpoll_send_skb
> and rebooted, and the laptop doesn't get back online. Bitten by
> recursion once again... I should have thought harder first.

My girlfriend told me what was outputted by my infinite loop:

netpoll: netif_running 1, netif_carrier_ok 0, netif_queue_stopped 0.

Shouldn't sungem stop its queue when there's no carrier ?

(I really hope to be able to spare a few hours in front of the laptop to
sort that out)
-- 
Colin

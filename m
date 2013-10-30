From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/3] r8152: modify the tx flow
Date: Wed, 30 Oct 2013 17:04:41 -0400 (EDT)
Message-ID: <20131030.170441.2031802071448773661.davem@davemloft.net>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
	<1383117220-893-1-git-send-email-hayeswang@realtek.com>
	<1383117220-893-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383117220-893-3-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 30 Oct 2013 15:13:39 +0800

> Remove the code for sending the packet in the rtl8152_start_xmit().
> Let rtl8152_start_xmit() to queue the packet only, and schedule a
> tasklet to send the queued packets. This simplify the code and make
> sure all the packet would be sent by the original order.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Basically, your driver will now queue up to 1,000 packets onto
this tx_queue list, because that is what tx_queue_len will be
for alloc_etherdev() allocated network devices.

In my previous reply to you about this patch, I asked you to
quantify and study the effects of using a limit of 60.  I said
that 60 might be too large.

You've responded by removing the limit completely, which is exactly
the opposite of what I've asked you to do.  Why did you do this?

This patch series is still not in a state where I can apply it,
sorry.

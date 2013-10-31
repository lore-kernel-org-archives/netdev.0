From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2 2/3] r8152: modify the tx flow
Date: Thu, 31 Oct 2013 13:52:38 +0800
Message-ID: <3FC2D94481C34A40A55B033CB9CFA9FB@realtek.com.tw>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com><1383117220-893-1-git-send-email-hayeswang@realtek.com><1383117220-893-3-git-send-email-hayeswang@realtek.com> <20131030.170441.2031802071448773661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131030.170441.2031802071448773661.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller [mailto:davem@davemloft.net] 
Sent: Thursday, October 31, 2013 5:05 AM
> 
> From: Hayes Wang <hayeswang@realtek.com>
> Date: Wed, 30 Oct 2013 15:13:39 +0800
[...]
> Basically, your driver will now queue up to 1,000 packets onto
> this tx_queue list, because that is what tx_queue_len will be
> for alloc_etherdev() allocated network devices.
> 
> In my previous reply to you about this patch, I asked you to
> quantify and study the effects of using a limit of 60.  I said
> that 60 might be too large.
> 
> You've responded by removing the limit completely, which is exactly
> the opposite of what I've asked you to do.  Why did you do this?

Excuse me. My question is that the original code doesn't stop the tx queue
either, so I don't understand why it is necessary for this patch.

I don't say I wouldn't find the suitable value for the tx queue length.
I feel I need some time to think how to find the reasonable value. And
I don't hope it influences the submission of the other patches, so I
remove it first. Or, may I submit the other two patches first?

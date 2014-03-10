From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 0/7] r8152: tx/rx improvement
Date: Mon, 10 Mar 2014 11:45:17 +0800
Message-ID: <084C9B4FE3DD41A2B6FFAA2A62F30692@realtek.com.tw>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com><1394161480-2918-1-git-send-email-hayeswang@realtek.com> <20140307.162732.1801095905509663010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307.162732.1801095905509663010.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, March 08, 2014 5:28 AM
> To: hayeswang@realtek.com
> Cc: netdev@vger.kernel.org; nic_swsd@realtek.com; 
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next 0/7] r8152: tx/rx improvement
[...]
> Note that if you ever add ->ndo_poll_controller support to 
> this driver,
> you will have to revert your spin_lock_irq{save,restore}() changes to
> your ->ndo_start_xmit.
> 
> Because the transmit function can indeed be invoked from hard IRQ
> context once you support netpoll.

Thank you for your reminder. I would notice that.

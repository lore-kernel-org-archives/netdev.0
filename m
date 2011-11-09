From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/temac: FIX segfault when process old irqs
Date: Wed, 09 Nov 2011 15:39:27 -0500 (EST)
Message-ID: <20111109.153927.1757753106148770956.davem@davemloft.net>
References: <1320744718-10916-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320744718-10916-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Tue,  8 Nov 2011 10:31:58 +0100

> Do not enable the irq until the scatter gather registers are ready to
> handle the data. Otherwise an irq from a packet send/received before
> last close can lead to an access to an invalid memory region on the irq
> handler.
> 
> Also, stop the dma engine on close.
> 
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>

Applied, thanks.

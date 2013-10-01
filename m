From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ll_temac: Reset dma descriptors indexes on ndo_open
Date: Tue, 01 Oct 2013 12:32:25 -0400 (EDT)
Message-ID: <20131001.123225.1741210078792586013.davem@davemloft.net>
References: <1380608230-29183-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jg1.han@samsung.com, gregkh@linuxfoundation.org,
	wfp5p@virginia.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380608230-29183-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Tue,  1 Oct 2013 08:17:10 +0200

> The dma descriptors indexes are only initialized on the probe function.
> 
> If a packet is on the buffer when temac_stop is called, the dma
> descriptors indexes can be left on a incorrect state where no other
> package can be sent.
> 
> So an interface could be left in an usable state after ifdow/ifup.
> 
> This patch makes sure that the descriptors indexes are in a proper
> status when the device is open.
> 
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>

Applied and queued up for -stable, thanks.

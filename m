From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Reset dma descriptors on ndo_open
Date: Mon, 30 Sep 2013 21:21:53 -0700 (PDT)
Message-ID: <20130930.212153.531876068589922786.davem@davemloft.net>
References: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jg1.han@samsung.com, gregkh@linuxfoundation.org,
	wfp5p@virginia.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Fri, 27 Sep 2013 13:24:28 +0200

> The dma descriptors are only initialized on the probe function.
> 
> If a packet is on the buffer when temac_stop is called, the dma
> descriptors can be left on a incorrect status where no other package can
> be sent.
> 
> So an interface could be left in an usable state after ifdow/ifup.
> 
> This patch makes sure that the descriptors are in a proper status when
> the device is started.
> 
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>

This analysis is not correct.

In the current driver, the descriptors are allocated and initialized
in the open function, not the probe function.

I'm not applying this patch.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_ncm: fix short packet issue on some devices
Date: Sun, 24 Apr 2011 22:35:29 -0700 (PDT)
Message-ID: <20110424.223529.226784817.davem@davemloft.net>
References: <20110424235930.GA11109@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	hselasky@c2i.net
To: greg@kroah.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110424235930.GA11109@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Sun, 24 Apr 2011 16:59:30 -0700

> From: Hans Petter Selasky <hselasky@c2i.net>
> 
> The default maximum transmit length for NCM USB frames should be so
> that a short packet happens at the end if the device supports a length
> greater than the defined maximum. This is achieved by adding 4 bytes
> to the maximum length so that the existing logic can fit a short
> packet there.
> 
> Signed-off-by: Hans Petter Selasky <hselasky@c2i.net>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Applied, thanks Greg.

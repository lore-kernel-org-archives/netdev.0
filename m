From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/gigaset: use USB API functions rather than
 constants
Date: Fri, 22 Aug 2014 12:27:25 -0700 (PDT)
Message-ID: <20140822.122725.770028169477728776.davem@davemloft.net>
References: <20140815162412.GA7192@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140815162412.GA7192@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 15 Aug 2014 21:54:12 +0530

> This patch introduces the use of the function usb_endpoint_num.
> 
> The Coccinelle semantic patch that makes these changes is as follows:
> 
> @@ struct usb_endpoint_descriptor *epd; @@
> 
> - (epd->bEndpointAddress & \(USB_ENDPOINT_NUMBER_MASK\|0x0f\))
> + usb_endpoint_num(epd)
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.

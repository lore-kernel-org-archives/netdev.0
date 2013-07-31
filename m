From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Wed, 31 Jul 2013 16:02:46 +0200
Message-ID: <1375279366.14846.1.camel@linux-fkkt.site>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <20130731124707.GA30635@kroah.com>
	 <CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38194 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754950Ab3GaOCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 10:02:48 -0400
In-Reply-To: <CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 21:50 +0800, Ming Lei wrote:

> In the usbnet case, the driver already supports non-sg well. Actually,
> all current drivers should support non-sg well because urb->sg wasn't
> introduced for very long time. We can think it as a new feature or DMA
> enhancement for xHCI controller.
> 
> If you mean buffer debounce for dma sg support on ehci/uhci/ohci/..,
> maybe we need to discuss and evaluate further.

We cannot lie to the networking layer. Either we can do sg in hardware
or we cannot. This is unfortunately determined by the HC not the device
on the bus. How else but from the host driver would we get the
information?

	Regards
		Oliver

From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Tue, 25 Aug 2015 14:36:38 +0200
Message-ID: <1440506198.13824.5.camel@suse.com>
References: <Pine.LNX.4.44L0.1508241419170.5935-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eugene.shatokhin@rosalab.ru,
	bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1508241419170.5935-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-08-24 at 14:21 -0400, Alan Stern wrote:
> > In theory, an architecture could implement atomic bit operations
> using 
> > a spinlock to insure atomicity.  I don't know if any architectures
> do 
> > this, but if they do then the scenario above could arise.
> 
> Now that I see this in writing, I realize it's not possible after
> all.  
> clear_bit() et al. will work with a single unsigned long, which
> doesn't
> leave any place for spinlocks or other mechanisms.  I was thinking of 
> atomic_t.

Refuting yourself you are making the assumption that the lock has
to be inside the data structure. That is not true.

	Regards
		Oliver

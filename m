From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 01/02] hso patch to fix a -EIO from opening a hso serial
 device
Date: Wed, 14 Jan 2009 13:04:20 +0000
Message-ID: <20090114130420.62574bc9@lxorguk.ukuu.org.uk>
References: <496DCAF7.9080906@option.com>
	<20090114113828.7b9f59ca@lxorguk.ukuu.org.uk>
	<496DDD42.6060601@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Linux Serial <linux-serial@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <496DDD42.6060601@option.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Your fix works too I suspect better than mine & since you've a better idea of what
> you are doing with tty layer than I do we'll stick with
> your fix.

Ok. 

> Do you want me to switch off the low latency stuff in the
> driver?

Lets leave it for now - it can get sorted properly when everything is
stable - no rush.

> I also need to investigate the tty_kref_put & tty_kref_get
> & when it was added to the kernel so I can fix stuff for our
> internal driver

About 2.6.27/28 and while it closes some small race conditions on exit
its not essential so probably not worth worrying about for older kernels

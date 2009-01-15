From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/02] hso patch to fix a -EIO from opening a hso
 serial device
Date: Wed, 14 Jan 2009 21:14:37 -0800 (PST)
Message-ID: <20090114.211437.139281407.davem@davemloft.net>
References: <496DCAF7.9080906@option.com>
	<20090114113828.7b9f59ca@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: D.Barow@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-serial@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20090114113828.7b9f59ca@lxorguk.ukuu.org.uk>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 14 Jan 2009 11:38:28 +0000

> On Wed, 14 Jan 2009 12:22:31 +0100
> Denis Joseph Barrow <D.Barow@option.com> wrote:
> 
> > Hi All,
> > This is an important patch the linux-2.6.29-rc1 driver with itworks much
> > better than it did.
> 
> How about this. 
> 
> tty: Fix a kref leak in the HSO driver on re-open
> 
> From: Alan Cox <alan@redhat.com>

Alan, if you could take this and the spinlock fix Danis also posted
(it's around a tty call: http://patchwork.ozlabs.org/patch/18412/), and
get them merged upstream, I'd appreciate it.

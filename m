From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Sat, 4 Mar 2006 14:35:33 +0300
Message-ID: <20060304113533.GA14248@2ka.mipt.ru>
References: <20060303214036.11908.10499.stgit@gitlost.site> <4408C2CA.5010909@garzik.org> <41b516cb0603031439n13e4df4cg8e5b21b606d2b4b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751477AbWCDLfq@vger.kernel.org>
To: chris.leech@gmail.com
Content-Disposition: inline
In-Reply-To: <41b516cb0603031439n13e4df4cg8e5b21b606d2b4b8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 02:39:22PM -0800, Chris Leech (christopher.leech@intel.com) wrote:
> > Patch #2 didn't make it.  Too big for the list?
> 
> Could be, it's the largest of the series.  I've attached the gziped
> patch.  I can try and split this up for the future.

How can owner of cb_chan->common.device_node be removed?
It looks like that channels are only allocated (without proper error path) 
and queued into device->common.channels list in
enumerate_dma_channels() in PCI probe callback and no removing at all, only lockless access.
PCI remove callback only calls dma_async_device_unregister() where only
channel's clients are removed.

> - Chris



-- 
	Evgeniy Polyakov

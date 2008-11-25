From: David Miller <davem@davemloft.net>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_mutex.patch
 [patch 4/6]
Date: Tue, 25 Nov 2008 02:22:46 -0800 (PST)
Message-ID: <20081125.022246.102969955.davem@davemloft.net>
References: <492ABECF.5050307@option.com>
	<20081125.003427.90695589.davem@davemloft.net>
	<20081125102043.0f318a8d@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: D.Barow@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752252AbYKYKWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 05:22:46 -0500
In-Reply-To: <20081125102043.0f318a8d@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 25 Nov 2008 10:20:43 +0000

> On Tue, 25 Nov 2008 00:34:27 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Denis Joseph Barrow <D.Barow@option.com>
> > Date: Mon, 24 Nov 2008 15:48:47 +0100
> > 
> > > A new structure hso_mutex_table had to be declared statically
> > > & used as as hso_device mutex_lock(&serial->parent->mutex) etc
> > > is freed in hso_serial_open & hso_serial_close by kref_put while
> > > the mutex is still in use.
> > > This is a substantial change but should make the driver much stabler.
> > > Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
> > 
> > Applied, but I had to fixup a lot of whitespace errors.
> 
> Dave - I don't put random network layer patches in the ttydev tree,
> please don't put random tty driver patches in the network tree. Those
> patches
> 
> a) are woefully inadequate
> b) will clash with the ttydev work which is where this belongs

I thought this was a network driver?

If so, this poor guy has respun these patches so many times
my head is spinning, and making him wait for one more procedural
thing is just a good way to deter yet another developer.

Most of these patches looked fine, is there a specific one I
should leave out?

I'm not leaving all of them out, most of them looked perfectly
fine and didn't do any "tty" stuff.

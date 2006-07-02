From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Two I/O memory regions in /proc/iomem for a NIC
Date: Sun, 2 Jul 2006 07:12:24 -0400
Message-ID: <20060702111224.GA6624@havoc.gtf.org>
References: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:4329 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932462AbWGBLM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 07:12:29 -0400
To: John Que <qwejohn@gmail.com>
Content-Disposition: inline
In-Reply-To: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 02, 2006 at 10:24:10AM +0300, John Que wrote:
> Hello,
> 
> I had noticed that there are machines where
> if I ran cat /proc/iomem I see one I/O memory region for the NIC
> I am using; while there are other machines where
> I see 2 regions for the NIC I/O memory.
> 
> For example, on a machine with e1000 NIC adapter,
> I see the following 2 I/O memory regions for the NIC:
> fc9a0000-fc9bffff : 0000:03:04.0
>    fc9a0000-fc9bffff : e1000
> fc9c0000-fc9dffff : 0000:03:03.0
>    fc9c0000-fc9dffff : e1000

There could be 1001 reasons.  Overall, it's not important :)

e1000 driver will reserve all regions made available by the PCI device.

	Jeff




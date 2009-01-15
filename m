From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 22:22:53 +0100
Message-ID: <200901152222.55006.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151853.52202.arnd@arndb.de> <20090115192129.GB9091@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	"Jan-Bernd Themann" <themann@de.ibm.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61307 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbZAOVXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 16:23:53 -0500
In-Reply-To: <20090115192129.GB9091@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2009, Ira Snyder wrote:
> I have another question for you Arnd.
> 
> What did you use as the host and guest drivers when you ran virtio over
> PCI? Did you use two unmodified instances of virtio_net (one on host,
> one on guest) for networking, or did you write new virtio drivers for
> those? How about for virtio_console (if you ran it at all).

Jan-Bernd may be able to tell you details about this, and send you the
driver code that his interns implemented for it.
This was only doing virtio_net between two machines using MMIO transfers,
i.e. the DMA engine was unused, but there was a mailbox interrupt (if you
have one of these, you won't need MSI, btw -- just write a DMA to it).

	Arnd <><

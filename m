From: "Leech, Christopher" <christopher.leech@intel.com>
Subject: RE: I/OAT configuration ?
Date: Fri, 18 Aug 2006 09:55:22 -0700
Message-ID: <BD524EA7912ED5469DFD0BAEF6BC752F29656A@orsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26665 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030498AbWHRQz0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 12:55:26 -0400
Content-class: urn:content-classes:message
To: <ravinandan.arakali@neterion.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Ravinandan Arakali
>
> Hi,
> I am trying to use I/OAT on one of the newer woodcrest boxes.
> But not sure if things are configured properly since there
> seems to be no change in performance with I/OAT enabled
> or disabled.
> Following are the steps followed.
> 1. MSI (CONFIG_PCI_MSI) is enabled in kernel(2.6.16.21).
> 2. In kernel DMA configuration, following are enabled.
>      Support for DMA Engines
>      Network: TCP receive copy offload
>      Test DMA Client
>      Intel I/OAT DMA support
> 3. I manually load the ioatdma driver (modprobe ioatdma)
> 
> As per some documentation I read, when step #3 is performed
> successfully, directories dma0chanX is supposed to be created
> under /sys/class/dma but in my case, this directory stays
> empty. I don't see any messages in /var/log/messages.
> Any idea what is missing ?

Does a PCI device with vendor ID 8086 and device ID 1a38 show up in
lspci?  That's the embedded DMA engine in the MCH.  It's only in the
5000 series chipsets, and may require a BIOS setting to enable.  It
should show up as bus 0 device 8 (00:08.0).

- Chris

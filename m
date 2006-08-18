From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: I/OAT configuration ?
Date: Thu, 17 Aug 2006 17:05:27 -0700
Message-ID: <003701c6c25a$034b0090$4010100a@pc.s2io.com>
References: <20060816005343.8634.21805.stgit@gitlost.site>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38855 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750843AbWHRAGp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 20:06:45 -0400
To: "'Chris Leech'" <christopher.leech@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
In-Reply-To: <20060816005343.8634.21805.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am trying to use I/OAT on one of the newer woodcrest boxes.
But not sure if things are configured properly since there
seems to be no change in performance with I/OAT enabled
or disabled.
Following are the steps followed.
1. MSI (CONFIG_PCI_MSI) is enabled in kernel(2.6.16.21).
2. In kernel DMA configuration, following are enabled.
     Support for DMA Engines
     Network: TCP receive copy offload
     Test DMA Client
     Intel I/OAT DMA support
3. I manually load the ioatdma driver (modprobe ioatdma)

As per some documentation I read, when step #3 is performed
successfully, directories dma0chanX is supposed to be created
under /sys/class/dma but in my case, this directory stays
empty. I don't see any messages in /var/log/messages.
Any idea what is missing ?

Thanks,
Ravi



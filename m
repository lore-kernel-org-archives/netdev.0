From: "Jay L. T. Cornwall" <jay@esuna.co.uk>
Subject: Re: [PATCH] atl1: disable 64bit DMA
Date: Mon, 25 Jun 2007 22:51:56 +0100
Message-ID: <468038FC.6090302@esuna.co.uk>
References: <467B12CA.5060405@esuna.co.uk> <467BE118.4090308@redhat.com> <467BE4F1.7040308@esuna.co.uk> <467D0EB0.9030100@esuna.co.uk> <20070624125957.2e27820c@osprey.hogchain.net> <467ED4A8.4080500@esuna.co.uk> <20070624164519.04f215b8@osprey.hogchain.net> <467FB237.2030703@esuna.co.uk> <467FB844.6060702@bellsouth.net> <20070625211855.GA19275@dreamland.darkstar.lan> <46803557.50805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jay Cliburn <jacliburn@bellsouth.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756265AbXFYVwY@vger.kernel.org>
In-Reply-To: <46803557.50805@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:

> What boards have we seen this on?  It's quite possible this is:

I can reproduce on an Asus P5K with a Core 2 Duo E6600.

lspci identifies the controller as:
  02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
  Ethernet Adapter (rev b0)

dmesg notes the PCI-DMA mapping implementation:
  PCI-DMA: Using software bounce buffering for IO (SWIOTLB)

-- 
Jay L. T. Cornwall, http://www.esuna.co.uk/~jay/
PhD Student
Imperial College London

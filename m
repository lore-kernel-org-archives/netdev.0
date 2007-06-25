From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] atl1: disable 64bit DMA
Date: Mon, 25 Jun 2007 17:57:20 -0400
Message-ID: <46803A40.4070009@redhat.com>
References: <467B12CA.5060405@esuna.co.uk> <467BE118.4090308@redhat.com> <467BE4F1.7040308@esuna.co.uk> <467D0EB0.9030100@esuna.co.uk> <20070624125957.2e27820c@osprey.hogchain.net> <467ED4A8.4080500@esuna.co.uk> <20070624164519.04f215b8@osprey.hogchain.net> <467FB237.2030703@esuna.co.uk> <467FB844.6060702@bellsouth.net> <20070625211855.GA19275@dreamland.darkstar.lan> <46803557.50805@redhat.com> <468038FC.6090302@esuna.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jay Cliburn <jacliburn@bellsouth.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Jay L. T. Cornwall" <jay@esuna.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754623AbXFYV56@vger.kernel.org>
In-Reply-To: <468038FC.6090302@esuna.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay L. T. Cornwall wrote:
> Chris Snook wrote:
> 
>> What boards have we seen this on?  It's quite possible this is:
> 
> I can reproduce on an Asus P5K with a Core 2 Duo E6600.
> 
> lspci identifies the controller as:
>   02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
>   Ethernet Adapter (rev b0)
> 
> dmesg notes the PCI-DMA mapping implementation:
>   PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> 

I had a hunch this was on Intel.  I'd rather just disable this when swiotlb is 
in use, unless we get more complaints.  It's probably ultimately a BIOS quirk 
anyway.

	-- Chris

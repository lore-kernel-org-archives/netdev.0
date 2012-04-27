From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 11:14:05 +0200
Message-ID: <20120427091405.GS3157@wantstofly.org>
References: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sedat Dilek <sedat.dilek@gmail.com>,
	stable@vger.kernel.org
To: Sedat Dilek <sedat.dilek@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 11:08:31AM +0200, Sedat Dilek wrote:

> User lautriv asked for belkin N-1 WLAN device support on IRC.
> 
> Further informations from lautriv:
> * marvell 80W8031, card-id 11ab:2a02
> * Debian/sid 3.2.x
> 
> On [1] I found a report by Jim Cromie concerning same PCI device-id:
> 
> 00:0e.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> 88W8361 [TopDog] 802.11n Wireless [11ab:2a02] (rev 03)
> 	Subsystem: Marvell Technology Group Ltd. 88W8361 [TopDog] 802.11n Wireless [11ab:2a02]
> 
> So, let's add 0x2a02 to PCI device table.

Let's not.  There's no firmware for the 8361 that implements the
firmware interface currently implemented by the mwl8k driver, so
this is pretty useless.


> [1] http://www.spinics.net/lists/newbies/msg46601.html

>From that link:

| I have a card which modprobes, despite a PCI-ID mismatch
|
| [...]
|
| Given the pci-id mismatch shouldnt this just fail to modprobe ?

No.  That's not a bug -- you are free to load drivers for hardware
not currently in your system.


>  static DEFINE_PCI_DEVICE_TABLE(mwl8k_pci_id_table) = {
> +	{ PCI_VDEVICE(MARVELL, 0x2a02), .driver_data = MWL8363, },
>  	{ PCI_VDEVICE(MARVELL, 0x2a0a), .driver_data = MWL8363, },

A 8361 is certainly not a 8363.

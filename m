From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sun, 21 Nov 2004 19:47:33 +0000
Message-ID: <41A0F0D5.9050702@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41A09541.5040405@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I've got it working with 10Mbps full-duplex now. Here are the lines from 
modprobe.conf:

   alias eth0 r8169
   options eth0 use_dac=0 media=0x2

I tried to build version 2.2 of the driver from RealTek 
<http://www.realtek.com.tw/> but that fails, because it uses 
pci_dma_sync_single(), which now appears to have been split into 
pci_dma_sync_single_for_cpu() and pci_dma_sync_single_for_device().

Looking at the specs for the 8169, I see there is a version called an 
8110SB. I wonder if I have that version? That might explain this message 
in the dmesg output:

   r8169: PCI device 0000:00:0c.0: unknown chip version, assuming RTL8169

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek

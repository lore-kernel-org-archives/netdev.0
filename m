From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [E1000-devel] e1000e suspend-to-disk reboots box with 3.11-rc3+
Date: Wed, 31 Jul 2013 21:13:10 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A184542E21F8@ORSMSX105.amr.corp.intel.com>
References: <20130731204040.GE4724@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Borislav Petkov <bp@alien8.de>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130731204040.GE4724@pd.tnic>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Borislav Petkov [mailto:bp@alien8.de]
> Sent: Wednesday, July 31, 2013 1:41 PM
> To: e1000-devel@lists.sourceforge.net
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [E1000-devel] e1000e suspend-to-disk reboots box with 3.11-rc3+
> 
> Hi,
> 
> I'm experiencing the strange observation that when I hibernate my x230
> with Linus HEAD from today + tip/master (3.11-rc3+), the box doesn't
> remain off but reboots immediately.
> 
> Since I have a similar bug where an e1000e box reboots
> when "Wake on LAN from S4/S5" is enabled in the BIOS
> (https://bugzilla.novell.com/show_bug.cgi?id=812592) I decided to test
> with LAN cable removed.
> 
> And yes, when the ethernet cable is not connected, the box hibernates
> and remains off. When I hibernate with the cable attached, the box
> doesn't remain off but reboots.
> 
> The card is:
> 
> [    1.620772] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
> [    1.622116] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
> [    1.623687] e1000e 0000:00:19.0: setting latency timer to 64
> [    1.625160] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to
> dynamic conservative mode
> [    1.626640] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
> [    1.884432] e1000e 0000:00:19.0 eth0: registered PHC clock
> [    1.885925] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1)
> 3c:97:0e:6b:ef:e7
> [    1.887466] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network
> Connection
> [    1.889089] e1000e 0000:00:19.0 eth0: MAC: 10, PHY: 11, PBA No: 1000FF-
> 0FF
> 
> And of course, 3.10 is fine.
> 
> Any ideas?
> 
> I'll try to bisect it when I get a chance.
> 
> --
> Regards/Gruss,
>     Boris.

Off the top of my head, I cannot think of anything that has been added to the driver in
Linus' tree since 3.10 that would cause this change in behavior.  There are a number of
changes that have been put into the out-of-tree driver which have not yet made it into
Linus' tree - would you be willing to try the latest out-of-tree driver from e1000.sf.net
to see if it resolves your issue?  Of course, a bisect as you mention would also help.

Have you checked for a BIOS update from your system manufacturer?
Do you have Runtime Power Management enabled for this device?

Thanks,
Bruce.

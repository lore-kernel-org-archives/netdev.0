From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12985] New: (atl2) Attansic L2 network card
 goes down.
Date: Wed, 1 Apr 2009 12:59:36 -0700
Message-ID: <20090401125936.68ec012e.akpm@linux-foundation.org>
References: <bug-12985-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jcliburn@gmail.com,
	csnook@redhat.com, jie.yang@atheros.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: madcored@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37577 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750927AbZDAUEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 16:04:23 -0400
In-Reply-To: <bug-12985-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Mar 2009 17:00:57 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12985
> 
>            Summary: (atl2) Attansic L2 network card goes down.
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: madcored@gmail.com
>         Regression: No
> 
> 
> After booting into 2.6.29 kernel my network card goes down without any reasons.
> But wifi-card(ath5k) seems work fine.
> 
> madeee:~# lspci |grep Ether
> 01:00.0 Ethernet controller: Atheros Communications Inc. AR242x 802.11abg
> Wireless PCI Express Adapter (rev 01)
> 03:00.0 Ethernet controller: Attansic Technology Corp. L2 100 Mbit Ethernet
> Adapter (rev a0)
> 
> 
> madeee:~# modinfo atl2
> filename:       /lib/modules/2.6.29-eee/kernel/drivers/net/atlx/atl2.ko
> version:        2.2.3
> license:        GPL
> description:    Atheros Fast Ethernet Network Driver
> author:         Atheros Corporation <xiong.huang@atheros.com>, Chris Snook
> <csnook@redhat.com>
> version:        2.1.3
> license:        GPL
> author:         Xiong Huang <xiong.huang@atheros.com>,  Chris Snook
> <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>
> srcversion:     CFB3AF8F8486BE7591B8BC5
> alias:          pci:v00001969d00002048sv*sd*bc*sc*i*
> depends:
> vermagic:       2.6.29-eee mod_unload modversions PENTIUMM
> parm:           TxMemSize:Bytes of Transmit Memory (array of int)
> parm:           RxMemBlock:Number of receive memory block (array of int)
> parm:           MediaType:MediaType Select (array of int)
> parm:           IntModTimer:Interrupt Moderator Timer (array of int)
> parm:           FlashVendor:SPI Flash Vendor (array of int)
> 
> madeee:~# uname -a
> Linux madeee 2.6.29-eee #2 Mon Mar 30 22:35:22 MSD 2009 i686 GNU/Linux

Is this a regression?  Was 2.6.28 OK?

Thanks.

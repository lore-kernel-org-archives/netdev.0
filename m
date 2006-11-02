From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Fw: [Bugme-new] [Bug 7450] New: e1000: eth0: e1000_clean_tx_irq:
 Detected Tx Unit Hang
Date: Thu, 02 Nov 2006 13:48:48 -0800
Message-ID: <454A67C0.6040201@intel.com>
References: <20061102112015.d4f5c60e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, pstaszewski@artcom.pl,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5706 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1752633AbWKBVsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 16:48:54 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061102112015.d4f5c60e.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 2 Nov 2006 06:41:04 -0800
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 7450] New: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7450
> 
>            Summary: e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>     Kernel Version: 2.6.19-rc3
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: pstaszewski@artcom.pl
> 
> 
> Most recent kernel where this bug did not occur: not known
> Distribution: Gentoo Linux x86_64
> Hardware Environment: 
> lspci
> 00:00.0 Host bridge: Intel Corporation E7230/3000/3010 Memory Controller Hub
> (rev c0)
> 00:01.0 PCI bridge: Intel Corporation E7230/3000/3010 PCI Express Root Port (rev c0)
> 00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1
> (rev 01)
> 00:1c.4 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express
> Port 5 (rev 01)
> 00:1c.5 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express
> Port 6 (rev 01)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1)
> 00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface
> Bridge (rev 01)
> 00:1f.2 SATA controller: Intel Corporation 82801GR/GH (ICH7 Family) Serial ATA
> Storage Controller AHCI (rev 01)
> 00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
> 01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09)
> 01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09)
> 01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09)
> 01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09)
> 0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet
> Controller (Copper) (rev 03)
> 0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
> 0f:04.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)
> 
> Software Environment: Iptables/Iproute2
> 
> Problem Description:
> e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>   Tx Queue             <0>
>   TDH                  <31>
>   TDT                  <31>

the hang is caused by a bad eeprom bit. A script that fixes it for 82573-series with 
eeproms that need this bit fixed is attached to the bugreport. It detects the proper 
chipset and patches if required (uses ethtool).

hth,

Auke

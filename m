From: "Hillier, Gernot" <gernot.hillier@siemens.com>
Subject: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro
 X7DB3
Date: Tue, 07 Oct 2008 16:25:37 +0200
Message-ID: <48EB7161.60004@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bruce.w.allan@intel.com
To: jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755475AbYJGOUj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

On at least two machines using the Supermicro X7DB3 board with Intel
82563EB (a.k.a. PCI device 8086:1096), we see sporadic problems on modprobe
(about 1 time in some hundred tries):

e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
e1000e 0000:06:00.0: setting latency timer to 64
0000:06:00.0: 0000:06:00.0: Hardware Error
0000:06:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:30:48:67:f5:f6
0000:06:00.0: eth0: Intel(R) PRO/1000 Network Connection
0000:06:00.0: eth0: MAC: 3, PHY: 5, PBA No: 2050ff-0ff
e1000e 0000:06:00.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
e1000e 0000:06:00.1: setting latency timer to 64
0000:06:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:30:48:67:f5:f7
0000:06:00.1: eth1: Intel(R) PRO/1000 Network Connection
0000:06:00.1: eth1: MAC: 3, PHY: 5, PBA No: 2050ff-0ff
0000:06:00.0: eth0: Hardware Error

eth0 is not available after module loading. During boot, this means the
machine won't come up correctly. Problem can be "fixed" by removing and
reloading the module.

This happens on the rather old SUSE-patched 2.6.25.11 with e1000e 0.2.0 as
well as with vanilla 2.6.27-rc8 including e1000e 0.3.3.3-k2.

The machines are equipped with two Quad-Core Xeons E5440 and 8GB of RAM.
Both kernels are compiled for x86_64.

Supermicro claims that there's no known hardware problem with these boards
and that the Windows driver doesn't show any issue...

Is there anything I can do to help narrowing down the problem? Anything I
can test? Any help greatly appreciated...

TIA!

-- 
Gernot Hillier
Siemens AG, CT SE 2, Corporate Competence Center Embedded Linux

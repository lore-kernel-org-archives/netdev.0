From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 0/9] Neterion: New driver: vxge: Resubmit #2
Date: 27 Mar 2009 14:53:39 -0800
Message-ID: <1238194418.5516.363.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:35486 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbZC0WJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:09:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of 9 patches are a resubmission of Neterion's new driver,
"vxge", for our latest PCIe based X3100 10GbE Server/Storage Adapter. 

Changes from the last submission -
1. Fixed compilation error on a 32 bit platform (x86) - added readq/writeq 
implementation for the driver for 32 bit systems - reported by Dave Miller.

2. Removed the pci-ids file from the patch series as it's been 
depricated - Dave Miller.

3. As per Stephen Hemminger's comments removed the following loadable 
parameters - gro, rx_& tx max_indicate_pkts, exec_mode, rx & tx pause_enable,
tx_steering_type and intr_type.

4. Some more clean up - removed a few unused statistics and variables.

Thanks,

Ram




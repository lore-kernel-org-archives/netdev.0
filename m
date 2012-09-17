From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: D-Link DGE-530T and r8169.c
Date: Mon, 17 Sep 2012 19:47:06 +0200
Message-ID: <20120917174706.GA24838@electric-eye.fr.zoreil.com>
References: <alpine.LNX.2.00.1209171139540.11109@hay.haya.qc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: "James R. Hay" <jrhay@haya.qc.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47665 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab2IQSFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 14:05:15 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1209171139540.11109@hay.haya.qc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James R. Hay <jrhay@haya.qc.ca> :
[...]
> At line 199 of r8169.c is the following:
> 
> 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
> 
> While I changed the 0x4300 to 0x4302 and recompiled the kernel to
> get the driver to recognize the card I believe that the appropriate
> fix would be to add the following line immediately after:
> 
> 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },

The ID above was added by 93a3aa25933461d76141179fc94aa32d5f9d954a between
v3.0 and v3.1. See: 

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=93a3aa25933461d76141179fc94aa32d5f9d954a

-- 
Ueimor

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sat, 23 Mar 2013 01:01:05 +0100
Message-ID: <20130323000105.GB939@order.stressinduktion.org>
References: <514CE440.3010003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: rebelyouth <rebelyouth.hacklab@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53080 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab3CWABH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 20:01:07 -0400
Content-Disposition: inline
In-Reply-To: <514CE440.3010003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 07:07:44PM -0400, rebelyouth wrote:
> 02:00.0 Ethernet controller: Atheros Communications Inc.
> 
> AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0)
> 
> Subsystem: ASUSTeK Computer Inc. Device 831c
> 
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> 
> ParErr- Stepping- SERR+ FastB2B- DisINTx+
> 
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> 
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 
> Latency: 0, Cache Line Size: 64 bytes
> 
> Interrupt: pin A routed to IRQ 45
> 
> Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=256K]
> 
> Region 2: I/O ports at ec00 [size=128]
> 
> Capabilities: <access denied>
> 
> Kernel driver in use: ATL1E

Could you show us the capabilities (running lspci -vv as root)? Please check
if ASPM is enabled and try to disable it in the BIOS.

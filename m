From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC Gigabit Ethernet is curious
Date: Wed, 30 Nov 2011 12:56:49 +0100
Message-ID: <201111301256.51123.carsten@wolffcarsten.de>
References: <jb0d7u$bbb$1@dough.gmane.org> <4ED4E946.40209@gmx.de> <20111129230404.GB11127@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Markus Feldmann <feldmann_markus@gmx.de>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:42919 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab1K3MSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 07:18:47 -0500
In-Reply-To: <20111129230404.GB11127@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wednesday 30 November 2011, Francois Romieu wrote:
> Markus Feldmann <feldmann_markus@gmx.de> :
> [...]
> 
> > You mean the latest Linux kernel was patched for a better
> > initialization? At the moment i am using the kernel 3.0.8. As i
> > understood the firmware must be loaded at every power on.
> 
> What do you mean ? Afaik there is no out-of-driver firmware for the
> (old) 8169sc.
> 
> Can either of you or Carsten compare and send 'lspci -vv' before and
> after windows installs ?

I'm sorry, I don't have that from before the windows install, the whole thing 
happened 2 years ago for me and I can not go back, obviously.

Anyway, this is the current lcpci ouput:

00:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC 
Gigabit Ethernet (rev 10)
        Subsystem: Jetway Information Co., Ltd. Device 10ec
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: I/O ports at bc00 [size=256]
        Region 1: Memory at dfaff000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at df900000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169

00:01.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC 
Gigabit Ethernet (rev 10)
        Subsystem: Jetway Information Co., Ltd. Device 10ec
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at b800 [size=256]
        Region 1: Memory at dfafe000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at df920000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2                                                                                                                       
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)                                                                                
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-                                                                                                      
        Kernel driver in use: r8169                                                                                                                                         
                                                                                                                                                                            
00:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC 
Gigabit Ethernet (rev 10)                                                                    
        Subsystem: Jetway Information Co., Ltd. Device 10ec                                                                                                                 
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-                                                               
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-                                                              
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 32 bytes                                                                                                    
        Interrupt: pin A routed to IRQ 16                                                                                                                                   
        Region 0: I/O ports at b400 [size=256]                                                                                                                              
        Region 1: Memory at dfafd000 (32-bit, non-prefetchable) [size=256]                                                                                                  
        Expansion ROM at df940000 [disabled] [size=128K]                                                                                                                    
        Capabilities: [dc] Power Management version 2                                                                                                                       
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)                                                                                
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-                                                                                                      
        Kernel driver in use: r8169

Regards
Carsten

From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [forcedeth bug] Re: [GIT] Networking
Date: Fri, 5 Aug 2011 14:18:55 +0200
Message-ID: <20110805121855.GC13055@elte.hu>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
 <20110801151308.GA31256@elte.hu>
 <20110804215354.GA7056@elte.hu>
 <20110805102239.GB1928@minipsycho.orion>
 <20110805102903.GF2420@elte.hu>
 <20110805112557.GD1928@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110805112557.GD1928@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jiri Pirko <jpirko@redhat.com> wrote:

> >> Is DEV_HAS_VLAN set in id->driver_data (L5344) ?
> >
> >How do i tell that without hacking the driver?
> 
> look in dmesg for line like:
> "forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi
> desc-v3"
> 
> if "vlan" is there, DEV_HAS_VLAN is set

[    3.534489] forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3

Note, this is a pretty old system with an old nvidia chipset and 
on-board ethernet:

00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
        Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0 (250ns min, 5000ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at da100000 (32-bit, non-prefetchable) [size=4K]
        Region 1: I/O ports at d000 [size=8]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable+ DSel=0 DScale=0 PME-

Thanks,

	Ingo

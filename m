From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash,
	Another Problem)
Date: Tue, 15 Jul 2008 20:56:46 +0200
Message-ID: <20080715185646.GA27023@electric-eye.fr.zoreil.com>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com> <1216052460.23392.14.camel@localhost> <200807142152.26163.eike-kernel@sf-tec.de> <487BB065.3020709@dell.com> <1216068344.23392.19.camel@localhost> <487BBE77.7050702@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kasper Sandberg <lkml@metanurb.dk>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Marcus Sundberg <marcus@ingate.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <487BBE77.7050702@dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mario Limonciello <mario_limonciello@dell.com> :
[...]
> If I was to guess (I didn't actually work out which one yours identifies
> as), most likely your NIC isn't caught in my check for MAC_VER_13 or
> MAC_VER_16, but Francois's patch has:

+1

(actually this change was contributed by Marcus Sundberg: see
the Signed-off-by and/or the patch named 
0003-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch)

I doubt that it will break anybody's 8101 (resp. 8102) but I would
welcome a report from a 8101/8102 owner before sending it upstream.

Sorry for disturbing linux-pci.

-- 
Ueimor

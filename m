From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
	Problem)
Date: Wed, 16 Jul 2008 17:03:18 +0200
Message-ID: <1216220598.10312.12.camel@localhost>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com>
	 <1216052460.23392.14.camel@localhost>
	 <200807142152.26163.eike-kernel@sf-tec.de> <487BB065.3020709@dell.com>
	 <1216068344.23392.19.camel@localhost> <487BBE77.7050702@dell.com>
	 <20080715185646.GA27023@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mario Limonciello <mario_limonciello@dell.com>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Marcus Sundberg <marcus@ingate.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080715185646.GA27023@electric-eye.fr.zoreil.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-07-15 at 20:56 +0200, Francois Romieu wrote:
> Mario Limonciello <mario_limonciello@dell.com> :
> [...]
> > If I was to guess (I didn't actually work out which one yours identifies
> > as), most likely your NIC isn't caught in my check for MAC_VER_13 or
> > MAC_VER_16, but Francois's patch has:
> 
> +1
> 
> (actually this change was contributed by Marcus Sundberg: see
> the Signed-off-by and/or the patch named 
> 0003-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch)
> 
> I doubt that it will break anybody's 8101 (resp. 8102) but I would
> welcome a report from a 8101/8102 owner before sending it upstream.

Yeah, this change will definetly be good news to lots of realtek pci
express owners, googling for this issue myself i found that alot of
people are having it, and finding it difficult/annoying to grab 8168
from realteks site, not to mention often compatibility issues, so this
is a very welcome fix :D

> 
> Sorry for disturbing linux-pci.
> 

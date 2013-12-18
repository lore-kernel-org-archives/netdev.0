From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: linux-next: build warning in Linus' tree
Date: Wed, 18 Dec 2013 02:54:37 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664685D5839F@ORSMSX110.amr.corp.intel.com>
References: <20131218095203.aceb7cfffffa16907feb9af7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131218095203.aceb7cfffffa16907feb9af7@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Rothwell
> Sent: Tuesday, December 17, 2013 2:52 PM
> To: David Miller; netdev@vger.kernel.org
> Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Fastabend,
> John R; Neil Horman
> Subject: linux-next: build warning in Linus' tree
> 
> Hi all,
> 
> While building Linus' tree, today's linux-next build (powerpc
> ppc64_defconfig) produced this warning:
> 
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c: In function
> 'ixgbe_pci_sriov_disable':
> drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c:294:6: warning: unused
> variable 'current_flags' [-Wunused-variable]
>   u32 current_flags = adapter->flags;
>       ^
> 
> Introduced by commit 2a47fa45d4df ("ixgbe: enable l2 forwarding
> acceleration for macvlans") which was merged before v3.13-rc1.
> 
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au


Hey Stephen,

Thanks for letting us know about this.   As it turns out we already have a patch to fix this in our internal tree (Jeff K's) just waiting final validation.  It shouldn't be long before he submits it.

Thanks again,
-Don Skidmore <donald.c.skidmore@intel.com>

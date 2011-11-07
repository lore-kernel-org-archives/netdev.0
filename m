From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the origin tree
Date: Sun, 06 Nov 2011 20:52:59 -0500 (EST)
Message-ID: <20111106.205259.1237400984015921904.davem@davemloft.net>
References: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 7 Nov 2011 10:12:02 +1100

> Starting with the origin tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
 ...
> Caused by commit 9487dc844054 ("ixgbe: Fix compiler warnings") which hid
> the declarations of ixgbe_disable_sriov() and ixgbe_check_vf_assignment()
> when CONFIG_PCI_IOV is not defined.
> 
> I have reverted that commit for today.

It should be fixed in net.git, can you please check that the build
succeeds after you pull it into -next?

If you just revert the commit in origin from -next, then you will get
conflicts with you pull the net.git tree in.

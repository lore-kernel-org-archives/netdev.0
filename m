From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Thu, 27 Sep 2012 22:19:43 -0400 (EDT)
Message-ID: <20120927.221943.19056434713380159.davem@davemloft.net>
References: <20120928114335.e05b34a5cfe716df86364ccf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ivecera@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120928114335.e05b34a5cfe716df86364ccf@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 28 Sep 2012 11:43:35 +1000

> Hi all,
> 
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> drivers/net/ethernet/emulex/benet/be_main.c: In function 'be_find_vfs':
> drivers/net/ethernet/emulex/benet/be_main.c:1090:28: error: 'struct pci_dev' has no member named 'physfn'
> 
> Caused by commit 51af6d7c1f31 ("be2net: fix vfs enumeration").  physfn is
> only defined if CONFIG_PCI_ATS is set.
> 
> I have reverted that commit for today.

I'm reverting it too, thanks for reporting Stephen.

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Tue, 13 Oct 2015 12:25:10 -0700
Message-ID: <20151013122510.0000429f@unknown>
References: <6607276.TY67sbLLqL@wuerfel>
	<1444717101.2870.16.camel@intel.com>
	<57023416.17EujnXPCo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
	<kbuild-all@01.org>, Andrew Bowers <andrewx.bowers@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	"John Ronciak" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10768 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290AbbJMTZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 15:25:12 -0400
In-Reply-To: <57023416.17EujnXPCo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Oct 2015 13:37:04 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Monday 12 October 2015 23:18:21 you wrote:
> > On Wed, 2015-10-07 at 22:13 +0200, Arnd Bergmann wrote:
> > > Jesse Brandeburg fixed a bug for 32-bit systems in the i40e driver
> > > in commit 9c70d7cebfec5 ("i40e: fix 32 bit build warnings"), but the
> > > same code still exists in the i40evf driver and causes compilation
> > > warnings in ARM and x86 allmodconfig:
> > > 
> > > drivers/net/ethernet/intel/i40evf/i40e_common.c:445:68: warning: cast
> > > from pointer to integer of different size [-Wpointer-to-int-cast]
> > > drivers/net/ethernet/intel/i40evf/i40e_common.c:446:71: warning: cast
> > > from pointer to integer of different size [-Wpointer-to-int-cast]
> > > 
> > > This applies the same fix by removing the broken code.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > 
> > Does not apply at all to my next-queue tree (dev-queue branch), my
> > guess is that this is already fixed in one of the patches already in my
> > queue.
> > 
> 
> I still get these warnings on your branch:

Make sure you're pulling from the dev-queue branch, not the master
branch of Jeff's next-queue repo.

I've made that mistake many times, and I do see that the code in
question is not present in:
https://git.kernel.org/cgit/linux/kernel/git/jkirsher/next-queue.git/tree/drivers/net/ethernet/intel/i40evf/i40e_common.c?h=dev-queue

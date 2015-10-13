From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Tue, 13 Oct 2015 12:33:58 -0700
Message-ID: <20151013123358.00005018@unknown>
References: <6607276.TY67sbLLqL@wuerfel>
	<1444717101.2870.16.camel@intel.com>
	<57023416.17EujnXPCo@wuerfel>
	<1444763132.2870.32.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>,
	<intel-wired-lan@lists.osuosl.org>, <kbuild-all@01.org>,
	Andrew Bowers <andrewx.bowers@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	"John Ronciak" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24373 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbbJMTeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 15:34:00 -0400
In-Reply-To: <1444763132.2870.32.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Oct 2015 12:05:32 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> On Tue, 2015-10-13 at 13:37 +0200, Arnd Bergmann wrote:
> > This is the majority of all build warnings we get on allmodconfig
> > (both i386 and arm),
> > so it would be really nice to have it fixed before 4.3. For all I can
> > tell, the
> > patch still applies on your branch too, but see below for the rebased
> > version.
> > 
> > I also note that your branch is not part of linux-next, is that
> > intentional?
> > 
> >         Arnd
> 
> Huh are you sure you used by dev-queue branch?  I ask because this is
> what I am getting when I try to apply your patch:
> 
> git am .apply/i40evf-fix-32-bit-build-warnings.patch
> Applying: Jesse Brandeburg fixed a bug for 32-bit systems in the i40e
> driver
> error: patch failed:
> drivers/net/ethernet/intel/i40evf/i40e_common.c:443
> error: drivers/net/ethernet/intel/i40evf/i40e_common.c: patch does not
> apply
> Patch failed at 0001 Jesse Brandeburg fixed a bug for 32-bit systems in
> the i40e driver
> The copy of the patch that failed is found in:
>    /home/jtkirshe/Public/next-queue/.git/rebase-apply/patch
> When you have resolved this problem, run "git am --continue".
> If you prefer to skip this patch, run "git am --skip" instead.
> To restore the original branch and stop patching, run "git am --abort".
> [12:02:27 @jtkirshe-linux:next-queue]$ patch -p1 <.apply/i40evf-fix-32
> -bit-build-warnings.patch 
> patching file drivers/net/ethernet/intel/i40evf/i40e_common.c
> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> Apply anyway? [n] 
> Skipping patch.
> 2 out of 2 hunks ignored -- saving rejects to file
> drivers/net/ethernet/intel/i40evf/i40e_common.c.rej
> [12:02:52 @jtkirshe-linux:next-queue]$
> 
> Even looking at the code, the code your changing does not exist in my
> dev-queue branch of my next-queue tree. 

it was already fixed via

commit 7890f6979a8eab436487396d6e2e0def8633fa16
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Tue Oct 13 11:15:46 2015 -0700

    i40evf: fix overlong BIT defines

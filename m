From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Wed, 30 Apr 2008 00:46:05 -0400
Message-ID: <20080430004605.4775469a.billfink@mindspring.com>
References: <1209521679.2827.23.camel@debian.sh.intel.com>
	<20080429.191754.29710117.davem@davemloft.net>
	<1209522667.2827.26.camel@debian.sh.intel.com>
	<20080429.193253.188598222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, linville@tuxdriver.com, jason@acm.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:50787 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755537AbYD3EqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 00:46:09 -0400
In-Reply-To: <20080429.193253.188598222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Apr 2008, David Miller wrote:

> From: Zhu Yi <yi.zhu@intel.com>
> Date: Wed, 30 Apr 2008 10:31:07 +0800
> 
> > On Tue, 2008-04-29 at 19:17 -0700, David Miller wrote:
> > > The build number increments every time you make.
> > > 
> > > That's where the "#nn" in the uname output comes from.
> > 
> > Well, if nothing is changed, why it tries to recompile the image? IIRC,
> > we don't have this problem in early kernels.
> 
> Something did change, the build number in the header file.

It doesn't do it in 2.6.22:

[root@lang2 linux-2.6.22.9-foo]# pwd
/home/extra/usr/src/kernels/linux-2.6.22.9-foo

[root@lang2 linux-2.6.22.9-foo]# strings - vmlinux | grep 'Linux vers'
Linux version 2.6.22.9-mf1 (root@lang2.eiger.nasa.atd.net) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #4 SMP Wed Apr 30 00:37:52 EDT 2008

[root@lang2 linux-2.6.22.9-foo]# make
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  MODPOST vmlinux
Kernel: arch/x86_64/boot/bzImage is ready  (#4)
  Building modules, stage 2.
  MODPOST 1605 modules

[root@lang2 linux-2.6.22.9-foo]# strings - vmlinux | grep 'Linux vers'
Linux version 2.6.22.9-mf1 (root@lang2.eiger.nasa.atd.net) (gcc version 4.1.1 20060525 (Red Hat 4.1.1-1)) #4 SMP Wed Apr 30 00:37:52 EDT 2008

This is as it should be I would think.

						-Bill

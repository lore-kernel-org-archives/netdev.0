From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87):
 Section mismatch in reference from the function sundance_probe1() to the
 variable .devinit.rodata:sundance_pci_tbl
Date: Wed, 5 Dec 2012 07:32:20 -0800
Message-ID: <20121205153220.GA3833@kroah.com>
References: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
 <CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild test robot <fengguang.wu@intel.com>,
	Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37785 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab2LEPaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 10:30:19 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3660271pad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 07:30:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 11:12:32AM +0300, Denis Kirjanov wrote:
> I"ll fix it.
> 
> Thanks.
> 
> On 12/5/12, kbuild test robot <fengguang.wu@intel.com> wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> > master
> > head:   193c1e478cc496844fcbef402a10976c95a634ff
> > commit: 64bc40de134bb5c7826ff384016f654219ed3956 dlink: remove __dev*
> > attributes
> > date:   27 hours ago
> > config: make ARCH=x86_64 allmodconfig
> >
> > All warnings:
> >
> > WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87): Section
> > mismatch in reference from the function sundance_probe1() to the variable
> > .devinit.rodata:sundance_pci_tbl
> > The function sundance_probe1() references
> > the variable __devinitconst sundance_pci_tbl.
> > This is often because sundance_probe1 lacks a __devinitconst
> > annotation or the annotation of sundance_pci_tbl is wrong.


No, no need to do this, it's fallout of the big dev* removal that is in
net-next right now, the warnings will go away when merged with my
driver-core-next tree which will happen in 3.8-rc1.

So please don't worry about it, it's a harmless message at the moment.

greg k-h

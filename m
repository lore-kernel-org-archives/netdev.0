From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87):
 Section mismatch in reference from the function sundance_probe1() to the
 variable .devinit.rodata:sundance_pci_tbl
Date: Wed, 5 Dec 2012 11:12:32 +0300
Message-ID: <CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
References: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47357 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab2LEIMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 03:12:33 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so4848757oag.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 00:12:32 -0800 (PST)
In-Reply-To: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I"ll fix it.

Thanks.

On 12/5/12, kbuild test robot <fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> master
> head:   193c1e478cc496844fcbef402a10976c95a634ff
> commit: 64bc40de134bb5c7826ff384016f654219ed3956 dlink: remove __dev*
> attributes
> date:   27 hours ago
> config: make ARCH=x86_64 allmodconfig
>
> All warnings:
>
> WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87): Section
> mismatch in reference from the function sundance_probe1() to the variable
> .devinit.rodata:sundance_pci_tbl
> The function sundance_probe1() references
> the variable __devinitconst sundance_pci_tbl.
> This is often because sundance_probe1 lacks a __devinitconst
> annotation or the annotation of sundance_pci_tbl is wrong.
>
> ---
> 0-DAY kernel build testing backend         Open Source Technology Center
> Fengguang Wu, Yuanhan Liu                              Intel Corporation
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

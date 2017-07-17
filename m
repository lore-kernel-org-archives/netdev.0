From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next:master 55/77] filter.c:undefined reference to `__dev_map_lookup_elem'
Date: Mon, 17 Jul 2017 15:41:47 -0700
Message-ID: <596D3D2B.4000804@gmail.com>
References: <201707180652.VZw98FDo%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35881 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751342AbdGQWl5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 18:41:57 -0400
Received: by mail-pf0-f194.google.com with SMTP id a11so347070pfj.3
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 15:41:57 -0700 (PDT)
In-Reply-To: <201707180652.VZw98FDo%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 03:20 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   24251c264798ac5a72667245c2650676d7ac2108
> commit: 97f91a7cf04ff605845c20948b8a80e54cbd3376 [55/77] bpf: add bpf_redirect_map helper routine
> config: x86_64-acpi-redef (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 97f91a7cf04ff605845c20948b8a80e54cbd3376
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    net/core/filter.o: In function `xdp_do_redirect_map':
>>> filter.c:(.text+0x430d): undefined reference to `__dev_map_lookup_elem'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

I missed this test,

# CONFIG_BPF_SYSCALL is not set

will have a fix shortly.

Thanks,
John

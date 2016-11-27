From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as hook
 priority instead of INT_MAX
Date: Sun, 27 Nov 2016 19:20:09 +0800
Message-ID: <CA+6hz4rHKr=wzXPXE_jNNFUf3hVPvv=L6TBveJZvR=apT+wd3g@mail.gmail.com>
References: <1480242245-7516-1-git-send-email-fgao@ikuai8.com> <201611271927.VjauNPub%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
        maheshb@google.com, Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:37438 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753768AbcK0LUV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 06:20:21 -0500
Received: from mail-ua0-f170.google.com (unknown [209.85.217.170])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 19:20:11 +0800 (CST)
Received: by mail-ua0-f170.google.com with SMTP id 20so116992060uak.0
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 03:20:11 -0800 (PST)
In-Reply-To: <201611271927.VjauNPub%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 7:17 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Gao,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/fgao-ikuai8-com/driver-ipvlan-Use-NF_IP_PRI_LAST-as-hook-priority-instead-of-INT_MAX/20161127-182724
> config: x86_64-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>>> drivers/net/ipvlan/ipvlan_main.c:19:15: error: 'NF_IP_PRI_LAST' undeclared here (not in a function)
>       .priority = NF_IP_PRI_LAST,
>                   ^~~~~~~~~~~~~~
>
> vim +/NF_IP_PRI_LAST +19 drivers/net/ipvlan/ipvlan_main.c
>
>     13
>     14  static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
>     15          {
>     16                  .hook     = ipvlan_nf_input,
>     17                  .pf       = NFPROTO_IPV4,
>     18                  .hooknum  = NF_INET_LOCAL_IN,
>   > 19                  .priority = NF_IP_PRI_LAST,
>     20          },
>     21          {
>     22                  .hook     = ipvlan_nf_input,
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Sorry, it broke the build.
I add the header file, but forget to commit, so that this patch does
not contain header file

Now I have sent the v2 patch.

Regards
Feng

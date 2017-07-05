From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [linux-next:master 10576/11031] ipsec_rxtx.c:undefined reference
 to `__udivdi3'
Date: Wed, 5 Jul 2017 14:32:10 +0300
Message-ID: <CAJ3xEMhqe7ojiNr4stUM_+bvr5heXgE8JMnBc04A1ex51eY+XA@mail.gmail.com>
References: <201707051144.MrtHWYTU%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>, kbuild-all@01.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36301 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdGELcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 07:32:12 -0400
Received: by mail-oi0-f51.google.com with SMTP id x187so65329342oig.3
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 04:32:11 -0700 (PDT)
In-Reply-To: <201707051144.MrtHWYTU%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 6:06 AM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   a70e9c77d0f09e7d00b62a8d618a61b2dfc5d889
> commit: b4fa2d8d19a3b6f15c51bb1c2993fb95405065bd [10576/11031] Merge remote-tracking branch 'net-next/master'
> config: i386-allyesconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout b4fa2d8d19a3b6f15c51bb1c2993fb95405065bd
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):
>
>    drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.o: In function `mlx5e_ipsec_build_inverse_table':
>>> ipsec_rxtx.c:(.text+0x668): undefined reference to `__udivdi3'

Hi Fengguang,

Ilan is handing that

Or.

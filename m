From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 07/14] tcp: export data delivery rate
Date: Fri, 16 Sep 2016 13:04:15 -0700
Message-ID: <1474056255.22679.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201609171104.7NaqQo41%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>, kbuild-all@01.org,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33403 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965448AbcIPUER (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:04:17 -0400
Received: by mail-pa0-f68.google.com with SMTP id oz2so3814813pac.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 13:04:17 -0700 (PDT)
In-Reply-To: <201609171104.7NaqQo41%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-09-17 at 11:56 +0800, kbuild test robot wrote:
> Hi Yuchung,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Neal-Cardwell/tcp-BBR-congestion-control-algorithm/20160917-025323
> config: arm-nhk8815_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 

Right, we need to include <asm/div64.h>  for some arches.

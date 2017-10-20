From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Fri, 20 Oct 2017 10:38:52 -0700
Message-ID: <1508521132.30291.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201710210027.nxMZ7dfs%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, edumazet@google.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:44275 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753316AbdJTRi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 13:38:56 -0400
Received: by mail-io0-f182.google.com with SMTP id m16so14038501iod.1
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 10:38:56 -0700 (PDT)
In-Reply-To: <201710210027.nxMZ7dfs%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-21 at 00:53 +0800, kbuild test robot wrote:
> Hi Eric,
> 
> [auto build test WARNING on net/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/dccp-tcp-fix-ireq-opt-races/20171021-001234
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 

Thanks, v4 of the patch should fix this.

https://patchwork.ozlabs.org/patch/828713/

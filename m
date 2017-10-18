From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sock_diag: request _diag module only when the family
 or proto has been registered
Date: Wed, 18 Oct 2017 21:33:58 +0800
Message-ID: <CADvbK_cuu+CZ8cN6oB8zichfw=1M7+cz-=zV-aJERvL=CuZGGg@mail.gmail.com>
References: <69c0824505548e733f2f7be3ff288f2c4e461afa.1508217236.git.lucien.xin@gmail.com>
 <201710181738.Tq0zphPS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild-all@01.org, network dev <netdev@vger.kernel.org>,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Eric Dumazet <edumazet@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:52083 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753809AbdJRNeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:34:00 -0400
Received: by mail-qk0-f195.google.com with SMTP id 17so6186560qkq.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 06:33:59 -0700 (PDT)
In-Reply-To: <201710181738.Tq0zphPS%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 5:38 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Xin,
>
> [auto build test ERROR on net/master]
>
> url:    https://github.com/0day-ci/linux/commits/Xin-Long/sock_diag-request-_diag-module-only-when-the-family-or-proto-has-been-registered/20171018-152434
> config: x86_64-randconfig-a0-10181611 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    net/core/sock_diag.o: In function `sock_diag_request_module':
>>> (.text+0x685): undefined reference to `inet_protos'
Huh,
# CONFIG_INET is not set
Cool, I will move the check for inet_protos to net_diag.ko
and repost.

Thanks.


>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

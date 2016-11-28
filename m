From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 1/2] sfc: separate out SFC4000 ("Falcon") support
 into new sfc-falcon driver
Date: Mon, 28 Nov 2016 11:29:47 +0000
Message-ID: <bfad810e-0086-166f-b426-142296604687@solarflare.com>
References: <201611260855.aKMo9XWI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kbuild-all@01.org>, <linux-net-drivers@solarflare.com>,
        <davem@davemloft.net>, <bkenward@solarflare.com>,
        <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:45800 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753732AbcK1LaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 06:30:01 -0500
In-Reply-To: <201611260855.aKMo9XWI%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/11/16 00:58, kbuild test robot wrote:
> Hi Edward,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Edward-Cree/sfc-split-out-Falcon-driver/20161126-033439
> config: i386-randconfig-h1-11260702 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> Note: the linux-review/Edward-Cree/sfc-split-out-Falcon-driver/20161126-033439 HEAD 738d215da7cf33cb4f2916dfba4fdb1558829e5a builds fine.
>       It only hurts bisectibility.
>
> All error/warnings (new ones prefixed by >>):
>
>    drivers/net/ethernet/sfc/falcon/built-in.o: In function `tenxpress_set_id_led':
>>> (.text+0x28db4): multiple definition of `tenxpress_set_id_led'
>    drivers/net/ethernet/sfc/built-in.o:(.text+0x3bac7): first defined here
Right, I have to do at least some of the rip-stuff-out in the first patch, else
building both drivers built-in breaks.  (I only tested building them as modules,
that was silly of me.)
Wondering if the right thing to do is just squash both patches together: it
could hardly make the series _less_ reviewable, and it might help git recognise
more of the copies as file renames.
Opinions?
-Ed

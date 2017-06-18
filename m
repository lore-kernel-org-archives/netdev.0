From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tls: update Kconfig
Date: Sat, 17 Jun 2017 22:57:03 -0400 (EDT)
Message-ID: <20170617.225703.799946534022098053.davem@davemloft.net>
References: <20170617152513.GA45696@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kbuild-all@01.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com,
        stephen@networkplumber.org
To: davejwatson@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdFRC5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 22:57:05 -0400
In-Reply-To: <20170617152513.GA45696@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Watson <davejwatson@fb.com>
Date: Sat, 17 Jun 2017 08:25:13 -0700

> Missing crypto deps for some platforms.
> Default to n for new module.
> 
> config: m68k-amcore_defconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 4.9.0
> 
> make.cross ARCH=m68k
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `tls_set_sw_offload':
>>> (.text+0x732f8): undefined reference to `crypto_alloc_aead'
>    net/built-in.o: In function `tls_set_sw_offload':
>>> (.text+0x7333c): undefined reference to `crypto_aead_setkey'
>    net/built-in.o: In function `tls_set_sw_offload':
>>> (.text+0x73354): undefined reference to `crypto_aead_setauthsize'
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Dave Watson <davejwatson@fb.com>

Applied, thanks Dave.

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next:master 300/401] nf_defrag_ipv6_hooks.c:undefined reference
 to `nf_ct_zone_dflt'
Date: Wed, 02 Sep 2015 10:31:05 +0200
Message-ID: <55E6B3C9.4040508@iogearbox.net>
References: <201509021529.WxsKStJ5%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>,
	Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36524 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbbIBIbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 04:31:12 -0400
In-Reply-To: <201509021529.WxsKStJ5%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 09:26 AM, kbuild test robot wrote:
> Hi Jiri,
>
> It's probably a bug fix that unveils the link errors.

I'll have a look, thanks!

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   20a17bf6c04e3eca8824c930ecc55ab832558e3b
> commit: 751a587ac9f9a8bf314590fbac32d9e418060c5a [300/401] route: fix breakage after moving lwtunnel state
> config: i386-randconfig-h0-09021408 (attached as .config)
> reproduce:
>    git checkout 751a587ac9f9a8bf314590fbac32d9e418060c5a
>    # save the attached .config to linux build tree
>    make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>     net/built-in.o: In function `ipv4_conntrack_defrag':
>     nf_defrag_ipv4.c:(.text+0x8e209): undefined reference to `nf_ct_zone_dflt'
>     nf_defrag_ipv4.c:(.text+0x8e21c): undefined reference to `nf_ct_zone_dflt'
>     nf_defrag_ipv4.c:(.text+0x8e2cb): undefined reference to `nf_ct_zone_dflt'
>     net/built-in.o: In function `ipv6_defrag':
>>> nf_defrag_ipv6_hooks.c:(.text+0xdb825): undefined reference to `nf_ct_zone_dflt'
>     nf_defrag_ipv6_hooks.c:(.text+0xdb846): undefined reference to `nf_ct_zone_dflt'
>     net/built-in.o:nf_defrag_ipv6_hooks.c:(.text+0xdb8ff): more undefined references to `nf_ct_zone_dflt' follow
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>

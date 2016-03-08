From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next:master 1077/1082] net/core/filter.c:1824:2: error:
 implicit declaration of function 'ip_tunnel_info_opts_get'
Date: Tue, 08 Mar 2016 21:32:27 +0100
Message-ID: <56DF36DB.8060404@iogearbox.net>
References: <201603090421.YL50GvPu%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53915 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbcCHUcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:32:32 -0500
In-Reply-To: <201603090421.YL50GvPu%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2016 09:20 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   f8b33d8e870758ccff13e5f81fd5050b52a42d35
> commit: 14ca0751c96f8d3d0f52e8ed3b3236f8b34d3460 [1077/1082] bpf: support for access to tunnel options
> config: x86_64-randconfig-i0-03080544 (attached as .config)
> reproduce:
>          git checkout 14ca0751c96f8d3d0f52e8ed3b3236f8b34d3460
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>     net/core/filter.c: In function 'bpf_skb_get_tunnel_opt':
>>> net/core/filter.c:1824:2: error: implicit declaration of function 'ip_tunnel_info_opts_get' [-Werror=implicit-function-declaration]
>       ip_tunnel_info_opts_get(to, info);
>       ^
>     net/core/filter.c: In function 'bpf_skb_set_tunnel_opt':
>>> net/core/filter.c:1918:2: error: implicit declaration of function 'ip_tunnel_info_opts_set' [-Werror=implicit-function-declaration]
>       ip_tunnel_info_opts_set(info, from, size);
>       ^
>     cc1: some warnings being treated as errors

Hmm, I see, it depends on CONFIG_INET, the rest of tunnel key API apparently not. :/

The attached .config here has:

# CONFIG_INET is not set

I'll send you a follow-up fix.

Thanks,
Daniel

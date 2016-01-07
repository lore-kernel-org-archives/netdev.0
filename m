From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add skb_postpush_rcsum and fix dev_forward_skb
 occasions
Date: Thu, 07 Jan 2016 10:05:41 +0100
Message-ID: <568E2A65.2020001@iogearbox.net>
References: <201601071158.XIjinbYM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net,
	alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41328 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcAGJFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:05:48 -0500
In-Reply-To: <201601071158.XIjinbYM%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 04:22 AM, kbuild test robot wrote:
> Hi Daniel,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/bpf-add-skb_postpush_rcsum-and-fix-dev_forward_skb-occasions/20160107-090423
> config: x86_64-lkp (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>     In file included from include/net/sch_generic.h:8:0,
>                      from include/linux/filter.h:16,
>                      from include/net/sock.h:64,
>                      from include/net/inet_sock.h:27,
>                      from include/net/ip.h:30,
>                      from net/core/filter.c:34:
>     net/core/filter.c: In function 'bpf_clone_redirect':
>>> net/core/filter.c:1530:19: error: 'struct sk_buff' has no member named 'tc_verd'
>        if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)

Hmm, right. I'll add an extra helper function then for v2 as we also
have such ifdef/else in other places for accessing tc_verd.

Thanks,
Daniel

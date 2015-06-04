From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [net-next:master 264/272] net/core/filter.c:1429:2: note: in
 expansion of macro 'if'
Date: Thu, 04 Jun 2015 08:07:22 -0700
Message-ID: <557069AA.80006@plumgrid.com>
References: <201506041854.P4RWFNh9%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35892 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbFDPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:07:25 -0400
Received: by pabqy3 with SMTP id qy3so31252632pab.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:07:24 -0700 (PDT)
In-Reply-To: <201506041854.P4RWFNh9%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/15 3:01 AM, kbuild test robot wrote:
> tree:git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git  master
> head:   c39c4c6abb89d24454b63798ccbae12b538206a5
> commit: 3896d655f4d491c67d669a15f275a39f713410f8 [264/272] bpf: introduce bpf_clone_redirect() helper
> config: x86_64-randconfig-i0-0604 (attached as .config)
> reproduce:
>    git checkout 3896d655f4d491c67d669a15f275a39f713410f8
>    # save the attached .config to linux build tree
>    make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>     In file included from include/uapi/linux/stddef.h:1:0,
>                      from include/linux/stddef.h:4,
>                      from include/uapi/linux/posix_types.h:4,
>                      from include/uapi/linux/types.h:13,
>                      from include/linux/types.h:5,
>                      from include/linux/list.h:4,
>                      from include/linux/module.h:9,
>                      from net/core/filter.c:24:
>     net/core/filter.c: In function 'bpf_clone_redirect':
>     net/core/filter.c:1429:18: error: 'struct sk_buff' has no member named 'tc_verd'
>       if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)

sorry. will get it fixed asap.

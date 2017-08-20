From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1184/1189] include/linux/bpf.h:324:21: error:
 'NUMA_NO_NODE' undeclared
Date: Sat, 19 Aug 2017 23:33:13 -0700 (PDT)
Message-ID: <20170819.233313.2054468070616685885.davem@davemloft.net>
References: <201708201349.qPOeS6kf%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdHTGdQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 02:33:16 -0400
In-Reply-To: <201708201349.qPOeS6kf%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Sun, 20 Aug 2017 13:43:54 +0800

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   228498596c44041c710f5a633904205bc1cd9177
> commit: 96eabe7a40aa17e613cf3db2c742ee8b1fc764d0 [1184/1189] bpf: Allow selecting numa node during map creation
> config: i386-randconfig-s1-201734 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 96eabe7a40aa17e613cf3db2c742ee8b1fc764d0
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from net/bpf/test_run.c:7:0:
>    include/linux/bpf.h: In function 'bpf_map_attr_numa_node':
>>> include/linux/bpf.h:324:21: error: 'NUMA_NO_NODE' undeclared (first use in this function)
>       attr->numa_node : NUMA_NO_NODE;
>                         ^~~~~~~~~~~~

I'll add the linux/numa.h include to linux/bpf.h

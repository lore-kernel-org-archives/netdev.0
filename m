From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] bpf: program testing framework
Date: Sat, 01 Apr 2017 13:05:44 -0700 (PDT)
Message-ID: <20170401.130544.1982531320045643109.davem@davemloft.net>
References: <20170331044543.4075183-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, wangnan0@huawei.com, kafai@fb.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdDAUFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 16:05:48 -0400
In-Reply-To: <20170331044543.4075183-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 30 Mar 2017 21:45:37 -0700

> Development and testing of networking bpf programs is quite cumbersome.
> Especially tricky are XDP programs that attach to real netdevices and
> program development feels like working on the car engine while
> the car is in motion.
> Another problem is ongoing changes to upstream llvm core
> that can introduce an optimization that verifier will not
> recognize. llvm bpf backend tests have no ability to run the programs.
> To improve this situation introduce BPF_PROG_TEST_RUN command
> to test and performance benchmark bpf programs.
> It achieves several goals:
> - development of xdp and skb based bpf programs can be done
> in a canned environment with unit tests
> - program performance optimizations can be benchmarked outside of
> networking core (without driver and skb costs)
> - continuous testing of upstream changes is finally practical
> 
> Patches 4,5,6 add C based test cases of various complexity
> to cover some sched_cls and xdp features. More tests will
> be added in the future. The tests were run on centos7 only.
> 
> For now the framework supports only skb and xdp programs. In the future
> it can be extended to socket_filter and tracing program types.
> 
> More details are in individual patches.
> 
> v1->v2:
> - rename bpf_program_test_run->bpf_prog_test_run
> - add missing #include <linux/bpf.h> since libbpf.h shouldn't depend
> on prior includes
> - reordered patches 3 and 4 to keep bisect clean

Series applied, thanks Alexei.

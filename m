From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Tue, 01 Nov 2016 11:48:18 -0400 (EDT)
Message-ID: <20161101.114818.117755564770907199.davem@davemloft.net>
References: <20161031183917.9938-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcKAPsU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:48:20 -0400
In-Reply-To: <20161031183917.9938-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Mon, 31 Oct 2016 11:39:14 -0700

> Update tools/lib/bpf to provide more functionality and improve interoperation
> with other tools that generate and use eBPF code.
> 
> The kernel uapi headers are a bit newer than the version in the tools/
> directory; synchronize those.
> 
> samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
> tools/lib/bpf/bpf* with these functions to bring them into parity.
> 
> tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
> map definition to be the same as in tc so the ELFs may be interchangeable
> (at least for now; I don't have a long-term plan in mind to ensure this always
> works).

Alexei and Daniel, please review.

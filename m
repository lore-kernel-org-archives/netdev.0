From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] bpf: Allow CGROUP_SKB eBPF program to
 access sk_buff
Date: Fri, 02 Jun 2017 14:24:59 -0400 (EDT)
Message-ID: <20170602.142459.680969091574833231.davem@davemloft.net>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdFBSZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:25:02 -0400
In-Reply-To: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Wed, 31 May 2017 18:15:59 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> This allows cgroup eBPF program to classify packet based on their
> protocol or other detail information. Currently program need
> CAP_NET_ADMIN privilege to attach a cgroup eBPF program, and A
> process with CAP_NET_ADMIN can already see all packets on the system,
> for example, by creating an iptables rules that causes the packet to
> be passed to userspace via NFLOG.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied.

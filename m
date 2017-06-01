From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] bpf: Allow CGROUP_SKB eBPF program to
 access sk_buff
Date: Thu, 1 Jun 2017 16:38:18 -0700
Message-ID: <20170601233817.tyxuusmvxv77isaa@ast-mbp>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36048 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751105AbdFAXiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 19:38:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id n23so9584436pfb.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 16:38:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 06:15:59PM -0700, Chenbo Feng wrote:
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

Acked-by: Alexei Starovoitov <ast@kernel.org>

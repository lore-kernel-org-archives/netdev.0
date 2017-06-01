From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Thu, 1 Jun 2017 16:42:36 -0700
Message-ID: <20170601234235.iwu55crijtxuq5mp@ast-mbp>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33413 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751105AbdFAXmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 19:42:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so9644354pfe.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 16:42:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 06:16:00PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
> capability while attaching the program to a cgroup only requires the
> user have CAP_NET_ADMIN privilege. We can escape the capability
> check when load the program just like socket filter program to make
> the capability requirement consistent.
> 
> Change since v1:
> Change the code style in order to be compliant with checkpatch.pl
> preference
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

as far as I can see they're indeed the same as socket filters, so
Acked-by: Alexei Starovoitov <ast@kernel.org>

but I don't quite understand how it helps, since as you said
attaching such unpriv fd to cgroup still requires root.
Do you have more patches to follow?

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] Add uid and cookie bpf helper to
 cg_skb_func_proto
Date: Mon, 17 Apr 2017 15:22:26 -0400 (EDT)
Message-ID: <20170417.152226.777719963255509302.davem@davemloft.net>
References: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, willemb@google.com,
        fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756612AbdDQTWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:22:33 -0400
In-Reply-To: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Fri, 14 Apr 2017 18:25:26 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> BPF helper functions get_socket_cookie and get_socket_uid can be
> used for network traffic classifications, among others. Expose
> them also to programs of type BPF_PROG_TYPE_CGROUP_SKB. As of
> commit 8f917bba0042 ("bpf: pass sk to helper functions") the
> required skb->sk function is available at both cgroup bpf ingress
> and egress hooks. With these two new helper, cg_skb_func_proto is
> effectively the same as sk_filter_func_proto.
> 
> Change since V1:
> Instead of add the helper to cg_skb_func_proto, redirect the
> cg_skb_func_proto to sk_filter_func_proto since all helper function
> in sk_filter_func_proto are applicable to cg_skb_func_proto now.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied, thanks.

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2] Add uid and cookie bpf helper to
 cg_skb_func_proto
Date: Fri, 14 Apr 2017 18:41:45 -0700
Message-ID: <20170415014143.GA80213@ast-mbp.thefacebook.com>
References: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35168 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdDOBlt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 21:41:49 -0400
Received: by mail-pg0-f51.google.com with SMTP id 72so40903610pge.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 18:41:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 06:25:26PM -0700, Chenbo Feng wrote:
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

Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>

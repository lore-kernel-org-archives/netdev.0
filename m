From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2] Add uid and cookie bpf helper to cg_skb_func_proto
Date: Sat, 15 Apr 2017 13:30:11 +0200
Message-ID: <58F20443.4040405@iogearbox.net>
References: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41615 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753553AbdDOLaO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 07:30:14 -0400
In-Reply-To: <1492219526-2945-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2017 03:25 AM, Chenbo Feng wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

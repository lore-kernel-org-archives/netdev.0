From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2] bpf: pass sk to helper functions
Date: Tue, 11 Apr 2017 11:14:41 -0700
Message-ID: <20170411181439.GA31880@ast-mbp.thefacebook.com>
References: <20170411180808.109636-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, fengc@google.com, lorenzo@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32952 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdDKSOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:14:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id c198so850972pfc.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 11:14:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170411180808.109636-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 02:08:08PM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> BPF helper functions access socket fields through skb->sk. This is not
> set in ingress cgroup and socket filters. The association is only made
> in skb_set_owner_r once the filter has accepted the packet. Sk is
> available as socket lookup has taken place.
> 
> Temporarily set skb->sk to sk in these cases.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

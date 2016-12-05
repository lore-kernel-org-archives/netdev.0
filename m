From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 05 Dec 2016 13:06:46 -0800
Message-ID: <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
        netdev@vger.kernel.org, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-12-05 at 15:28 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Add support for attaching an eBPF object by file descriptor.
> 
> The iptables binary can be called with a path to an elf object or a
> pinned bpf object. Also pass the mode and path to the kernel to be
> able to return it later for iptables dump and save.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Assuming there is no simple way to get variable matchsize in iptables,
this looks good to me, thanks.

Reviewed-by: Eric Dumazet <edumazet@google.com>





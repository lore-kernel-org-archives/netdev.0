From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Sat, 26 Jul 2014 12:18:47 +0200
Message-ID: <20140726101847.GA3703@salvia>
References: <1406315469-20010-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406315469-20010-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 12:11:09PM -0700, Alexei Starovoitov wrote:
> 'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
> as variable 'sk_filter', which makes code hard to read.
> Also it's easily confused with 'struct sock_filter'
> Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
> align the name with generic BPF use model.
> 
> The only ugly place is uapi/linux/netfilter/xt_bpf.h which
> managed to expose kernel internal structure into uapi header.
> So replace 'struct sk_filter *' there with 'void *' and type cast it
> to 'struct bpf_prog *' inside kernel in net/netfilter/xt_bpf.c
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v1->v2:
> replace 'struct sk_filter *' with 'void *' in uapi/../xt_bpf.h
> (seems Daniel and Willem prefere this option)

Please, we're still discussing this in the original thread:

http://marc.info/?l=netfilter-devel&m=140632686726741&w=2
http://marc.info/?l=netfilter-devel&m=140632663526671&w=2

And don't trim me off from the CC. Thanks.

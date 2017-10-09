From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of
 'xt_bpf_info_v1'
Date: Mon, 9 Oct 2017 13:18:23 +0200
Message-ID: <20171009111823.GA30637@salvia>
References: <20171006160242.4403-1-shmulik@nsof.io>
 <CAF=yD-JbZ_ViWsBWK7Ye=4RYF9BgnMKvD04xE5P26RNRpnmuiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shmulik Ladkani <shmulik@nsof.io>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Rafael Buchbinder <rafi@rbk.ms>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-JbZ_ViWsBWK7Ye=4RYF9BgnMKvD04xE5P26RNRpnmuiQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2017 at 01:40:13PM -0400, Willem de Bruijn wrote:
> On Fri, Oct 6, 2017 at 12:02 PM, Shmulik Ladkani <shmulik@nsof.io> wrote:
> > From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> >
> > Commit 2c16d6033264 ("netfilter: xt_bpf: support ebpf") introduced
> > support for attaching an eBPF object by an fd, with the
> > 'bpf_mt_check_v1' ABI expecting the '.fd' to be specified upon each
> > IPT_SO_SET_REPLACE call.
> >
> > However this breaks subsequent iptables calls:
> >
> >  # iptables -A INPUT -m bpf --object-pinned /sys/fs/bpf/xxx -j ACCEPT
> >  # iptables -A INPUT -s 5.6.7.8 -j ACCEPT
> >  iptables: Invalid argument. Run `dmesg' for more information.
[...]
> >
> > References: [1] https://marc.info/?l=netfilter-devel&m=150564724607440&w=2
> >             [2] https://marc.info/?l=netfilter-devel&m=150575727129880&w=2
> >
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: Willem de Bruijn <willemb@google.com>
> > Reported-by: Rafael Buchbinder <rafi@rbk.ms>
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> Acked-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.

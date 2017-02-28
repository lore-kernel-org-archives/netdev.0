From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [4.9.10] ip_route_me_harder() reading off-slab
Date: Tue, 28 Feb 2017 12:50:02 +0100
Message-ID: <20170228115002.GA20068@salvia>
References: <CAMVG2ssKxnEsu4=orZyB3UsHwT2CZhpWKFn2UmtoPOEu1KMHPw@mail.gmail.com>
 <20170217073928.GA25854@breakpoint.cc>
 <CAMVG2ssH8F-BgUzCxZdcAYgYo_2HMK_0=drg-JS596TT7A=5wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jan Beulich <JBeulich@suse.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netfilter-devel@vger.kernel.org
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMVG2ssH8F-BgUzCxZdcAYgYo_2HMK_0=drg-JS596TT7A=5wA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 10:41:48PM +0800, Daniel J Blueman wrote:
> On 17 February 2017 at 15:39, Florian Westphal <fw@strlen.de> wrote:
> > Daniel J Blueman <daniel@quora.org> wrote:
> >
> > [ CC nf-devel, pablo ]
> >
> >> When booting a VM in libvirt/KVM attached to a local bridge and KASAN
> >> enabled on 4.9.10, we see a stream of KASAN warnings about off-slab
> >> access [1].
> >>
> >> Let me know if you'd like more debug.
> >
> > Does this patch help?
> >
> > Subject: [PATCH nf] netfilter: use skb_to_full_sk in ip_route_me_harder
> >
> > inet_sk(skb->sk) is illegal in case skb is attached to request socket.
> >
> > Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> > Reported by: Daniel J Blueman <daniel@quora.org>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
[...]
> Apologies for the delays; this also addresses the issue just fine.
> 
> Tested-by: Daniel J Blueman <daniel@quora.org>

Applied, thanks for testing.

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: SYNPROXY: fix process non tcp packet bug
 in {ipv4,ipv6}_synproxy_hook
Date: Tue, 3 Oct 2017 15:32:06 +0200
Message-ID: <20171003133206.GA19459@salvia>
References: <1506767115-10051-1-git-send-email-xiaolou4617@gmail.com>
 <20171003132825.GA11182@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171003132825.GA11182@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2017 at 03:28:25PM +0200, Pablo Neira Ayuso wrote:
> On Sat, Sep 30, 2017 at 06:25:15PM +0800, Lin Zhang wrote:
> > In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
> > but the real server maybe reply an icmp error packet related to the 
> > exist tcp conntrack, so we will access wrong tcp data.
> > 
> > For fix it, check for the protocol field and only process tcp traffic.
> 
> Applied, thanks.
> 
> I have made minor comestic changes to patch title:
> 
> netfilter: SYNPROXY: skip non-TCP packets from {ipv4,ipv6}_synproxy_hook
> 
> for the record.

I have to keep this back, sorry.

This has been not compiled tested.

net/ipv6/netfilter/ip6t_SYNPROXY.c: In function ‘ipv6_synproxy_hook’:
net/ipv6/netfilter/ip6t_SYNPROXY.c:351:19: error: ‘struct ipv6hdr’ has
no member named ‘protocol’
      ipv6_hdr(skb)->protocol != IPPROTO_TCP)
                   ^

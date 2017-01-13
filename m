From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flow disector: check if arp_eth is null rather than arp
Date: Fri, 13 Jan 2017 10:36:15 -0800
Message-ID: <1484332575.13165.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170113133428.20130-1-colin.king@canonical.com>
         <1484331851.13165.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <7b26e04c-b3f1-a82f-8f18-d93207388a28@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Simon Horman <simon.horman@netronome.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Amir Vadai <amir@vadai.me>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7b26e04c-b3f1-a82f-8f18-d93207388a28@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-13 at 18:25 +0000, Colin Ian King wrote:
> On 13/01/17 18:24, Eric Dumazet wrote:

> > It looks that we try very hard to add critical bugs in flow dissector.
> > 
> > This is embarrassing really.
> > 
> > I am questioning if the __skb_header_pointer() is correct
> > 
> > Why using hlen - sizeof(_arp) ?
> > 
> >                arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
> >                                               sizeof(_arp_eth), data,
> >                                               hlen - sizeof(_arp),
> >                                               &_arp_eth);
> > 
> 
> Yep, the sizeof maybe dubious too, I overlooked that one; if somebody
> can clarify that then I'll send a V2 if it needs fixing up too.

I am pretty sure we should use hlen instead of (hlen - sizeof(_arp))

A V2 would be nice ;)

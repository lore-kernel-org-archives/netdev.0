From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 01:04:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010010439.C8102@edi-view1.cisco.com>
References: <20021010002902.A3803@edi-view1.cisco.com> <20021009.162438.82081593.davem@redhat.com> <uu1jv9o3j.wl@sfc.wide.ad.jp> <20021009.164504.28085695.davem@redhat.com> <ur8ez9n8d.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
In-Reply-To: <ur8ez9n8d.wl@sfc.wide.ad.jp>; from sekiya@sfc.wide.ad.jp on Thu, Oct 10, 2002 at 09:00:34AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2002 at 09:00:34AM +0900, Yuji Sekiya wrote:
> At Wed, 09 Oct 2002 16:45:04 -0700 (PDT),
> ** David S. Miller <davem@redhat.com> wrote:
> 
> >    The reason we change the prefix length  from /10 to /64 is
> >    following spec and adapting other imprementations.
> > 
> > I think Derek's explanation shows that the specification
> > allows the /10 behavior.
> 
> Hmm... we interpret the spec as /64 prefix.
> 
> > Also, I suspect that since Derek works for Cisco, some "other
> > implementations" behave how he describes. :-)
> 
> I have cisco box which installed IPv6 IOS.
> But it defines no prefix length at an interface,
> 
> FastEthernet4/1 is up, line protocol is up
>   IPv6 is enabled, link-local address is FE80::201:64FF:FEA3:ED55
> 
> and outgoing interface of routing table is NULL ? :-)
> 
> L   FE80::/10 [0/0]
>      via ::, Null0, 7w0d

Turn on 'debug ipv6 nd',  'debug ipv6 icmp',  'debug ipv6 pack d'

Then do 'ping ipv6' specify a link local of say fe80:1910::10 and
an egress interface,  and watch what happens.

DF

From: Lincoln Dale <ltd@cisco.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sun, 23 Jun 2002 12:05:44 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <5.1.0.14.2.20020623120148.0399aae8@mira-sjcm-3.cisco.com>
References: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: vonbrand@inf.utfsm.cl (Horst von Brand),
   davem@redhat.com (David S. Miller), greearb@candelatech.com (Ben Greear),
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <E17LwjD-0003hT-00@the-village.bc.nu>
List-Id: netdev.vger.kernel.org

g'day Alan,

At 03:03 AM 23/06/2002 +0100, you wrote:
> > i know of many many folk who use transaction logs from HTTP caches for
> > volume-based billing.
> > right now, those bills are anywhere between 10% to 25% incorrect.
> >
> > you call that "extremely limited"?
>
>It wouldnt help you anyway. Prove which frames were not due to the
>overloading and congestion/errors on your network which therefore the 
>customer should
>not have a duty to pay. Account for bitstuffing on HDLC links...

sure - but these are all Layer-8 (politics) and layer-9 (religion) issues.

typically Service Providers on this side of the planet handle that side of 
things via SLAs internal to their own network.  i.e. "we guarantee X% 
uptime, less than Y% packet-loss across our own core network as measured 
using XXYYZZ method".

the fact that an IP packet may have a PPP header on it across one hop, a 
HDLC header across another, perhaps some MPLS labels across another, 
802.1q-in-802.1q across another is generally immaterial.
if you did want to get fancy and account for it, at least you have 
packet-counters on a per-socket basis from which to do that with.
without per-socket accounting, you just don't have that anyway.


cheers,

lincoln.

From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 17:32:49 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.3.96.1030818171100.2101C-100000@gatekeeper.tmr.com>
References: <20030817223118.3cbc497c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Willy Tarreau <willy@w.ods.org>, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030817223118.3cbc497c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Aug 2003, David S. Miller wrote:

> On Mon, 18 Aug 2003 00:48:49 +0200
> Willy Tarreau <willy@w.ods.org> wrote:
> 
> > On Sun, Aug 17, 2003 at 06:24:06PM +0100, Alan Cox wrote:
> >  
> > > So stick the address on eth0 not on lo since its not a loopback but an eth0
> > > address, then use arpfilter so you don't arp for the invalid magic shared IP
> > > address, or NAT it, or it may work to do
> > > 
> > >          ip route add nexthop-addr src my-virtual-addr dev eth0 scope local onlink
> > >          ip route add default src my-virtual-addr via nexthop-addr dev eth0 scope global
> >  
> > I have a case where this doesn't work
> 
> Replying again... Alan does mention in the paragraph you've quoted
> to use arpfilter, which works for every case imaginable.

Okay, I'll show my ignorance and ask... the Documentation for arp_filter
says source routing must be used. Is there some flag I'm missing, or a way
to avoid having a rule per address, or is the 8 bit rule number larger in
2.6, or ??? Or is having a lot of IPs on one machine not an imaginable
case?

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

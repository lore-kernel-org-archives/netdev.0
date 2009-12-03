From: Ming-Ching Tiew <mctiew@yahoo.com>
Subject: Re: match SIP & RTP packets
Date: Thu, 3 Dec 2009 03:50:00 -0800 (PST)
Message-ID: <582211.62204.qm@web31506.mail.mud.yahoo.com>
References: <4B179CD8.2080002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B179CD8.2080002@trash.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- On Thu, 12/3/09, Patrick McHardy <kaber@trash.net> wrote:

> From: Patrick McHardy <kaber@trash.net>
> Subject: Re: match SIP & RTP packets
> To: "Lorenzo Allegrucci" <lorenzo.allegrucci@forinicom.it>
> Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
> Date: Thursday, December 3, 2009, 11:11 AM
> Lorenzo Allegrucci wrote:
> > 
> > Hi all, it's not clear to me whether nf_conntrack_sip
> does SIP and RTP
> > connection
> > tracking or just SIP.. can you clarify?
> > I need to match both SIP and RTP packets and I was
> wondering if the rule
> > below would satisfy my requirements:
> > 
> > iptables -t mangle -A FORWARD -o eth0 -m helper
> --helper sip -j CLASSIFY
> > --set-class 1:1
> 
> Almost, this will match on RTP packets and incoming
> signalling
> connections (-m helper matches on expected connections).
> What's
> missing is the original signalling connection on port
> 5060.
> --

So there is no way to identify it based on NEW connection state ?

(... Want to route new SIP calls to different locations .... )

Regards.


      

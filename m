From: David Miller <davem@davemloft.net>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
 latest -git
Date: Sat, 19 Apr 2008 17:54:05 -0700 (PDT)
Message-ID: <20080419.175405.91059921.davem@davemloft.net>
References: <20080419100034.GA9475@elte.hu>
	<20080419.030736.168169087.davem@davemloft.net>
	<480A2011.3080507@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <480A2011.3080507@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 19 Apr 2008 18:38:41 +0200

> David Miller wrote:
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Sat, 19 Apr 2008 12:00:35 +0200
> >
> > [ netfilter-devel and netdev added to CC: ]
> >
> >   
> >> randconfig testing found a netfilter build failure in latest -git:
> >>
> >>   net/netfilter/nf_conntrack_sip.c: In function 'set_expected_rtp_rtcp':
> >>   net/netfilter/nf_conntrack_sip.c:786: error: 'struct nf_conntrack_expect' has no member named 'saved_ip'
> >>
> >>   http://redhat.com/~mingo/misc/config-Sat_Apr_19_11_37_02_CEST_2008.bad
> >>
> >> disabling CONFIG_NF_CONNTRACK_SIP works it around.
> >>     
> >
> > I think this will fix it.
> >
> > Patrick, is this how we should do it?
> 
> No, the SIP helper is also useful without NAT. This patch adds
> an ifdef around the RTP call optimization for NATed clients.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Fair enough, applied, thanks Patrick.

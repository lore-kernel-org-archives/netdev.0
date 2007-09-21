From: lepton <ytht.net@gmail.com>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Fri, 21 Sep 2007 22:07:20 +0800
Message-ID: <20070921140720.GA10419@router.lepton.home>
References: <20070919093648.GA7491@router.lepton.home> <46F13999.30700@trash.net> <46F13D7D.6010603@trash.net> <20070919155554.GA11710@router.lepton.home> <46F3BB9E.4000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46F3BB9E.4000105@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes.
My situation is:
The default route device is a e1000 network card that can do TSO.
So the tcp stack will try send big skb to netfilter frame work.
But after rerouting, the packtes will go out from a device  that
can not do TSO. the packet is just get dropped..

I thinks if we can't get a way to tell tcp stack the sk_route_caps of 
the real out device, we can just disable all things for safety.

On Fri, Sep 21, 2007 at 02:39:58PM +0200, Patrick McHardy wrote:
> lepton wrote:
> > Yes, you are right.
> > What do you think about this:
> > For all packets can be sent out, we just disable 
> > all things in sk_route_caps in ip_route_me_harder
> 
> 
> Whats the point of doing that? Is rerouting breaking anything for you?

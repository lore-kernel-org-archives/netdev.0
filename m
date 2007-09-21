From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Fri, 21 Sep 2007 16:57:42 +0200
Message-ID: <46F3DBE6.90205@trash.net>
References: <20070919093648.GA7491@router.lepton.home> <46F13999.30700@trash.net> <46F13D7D.6010603@trash.net> <20070919155554.GA11710@router.lepton.home> <46F3BB9E.4000105@trash.net> <20070921140720.GA10419@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: lepton <ytht.net@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20070921140720.GA10419@router.lepton.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lepton wrote:
> My situation is:
> The default route device is a e1000 network card that can do TSO.
> So the tcp stack will try send big skb to netfilter frame work.
> But after rerouting, the packtes will go out from a device  that
> can not do TSO. the packet is just get dropped..
> 
> I thinks if we can't get a way to tell tcp stack the sk_route_caps of 
> the real out device, we can just disable all things for safety.


As you already noticed yourself (in private email), this is
handled properly in current kernels.


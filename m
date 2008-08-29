From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Fri, 29 Aug 2008 19:57:09 +0300
Message-ID: <200808291957.10007.denys@visp.net.lb>
References: <48B44768.3030208@gmail.com> <200808281250.35006.denys@visp.net.lb> <48B82843.4090707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lachlan.andrew@gmail.com
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:42404 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbYH2Q6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 12:58:38 -0400
In-Reply-To: <48B82843.4090707@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 29 August 2008, Tom Quetchenbach wrote:
> In my case I don't think the iptables workaround is the right solution.
> I'm working on a traffic generator (tmix, from the University of North
> Carolina), that starts many simultaneous flows between two endpoints,
> based on a set of "connection vectors" derived from a tcpdump. The MSS
> for each flow is specified in the connection vector file on a per-flow
> basis. So it's not so simple as clamping the MSS to the path MTU or
> setting it based on some simple criteria like destination or port
> number. I'm sure I could hack something together using iptables to
> approximate what I want to do, but it seems like a bit of a mess to me.
>
> I'm not that familiar with iptables so please correct me if I'm wrong.
Sure proper fix always better.
My case MUCH simplier (i know that all endpoints have lower than 1500 MTU, so 
i just set required value for all SYN requests to that direction).

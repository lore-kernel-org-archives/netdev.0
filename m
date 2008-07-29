From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: incoming interface + ifb0
Date: Tue, 29 Jul 2008 16:26:36 +0300
Message-ID: <200807291626.36572.denys@visp.net.lb>
References: <20080729124823.GA26788@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:43942 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536AbYG2N07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 09:26:59 -0400
In-Reply-To: <20080729124823.GA26788@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 July 2008, Jarek Poplawski wrote:

> I didn't use this nor checked enough, so I can be wrong, but
> since ingress with ifb0 is in prerouting, you probably can't use
> rt_iif. You shouldn't filter at ifb on "dev" neither - it's "ifb"
> at the moment. You need to match skb->iif with something (flow?).
Yes
I want to create on outgoing device or ifb(preffered) - tree of flows.
Cause each interface = customer - i need to classify customers by flows.

Since customer can have multiple/spoofed ip's - i cannot filter by ip for now.
So iif only my choice seems.

Maybe if i do redirect on outgoing to ifb on outgoing device it will work?


>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



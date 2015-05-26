From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF
 reassembed skbs
Date: Tue, 26 May 2015 11:57:25 +0200
Message-ID: <1432634245.17881.57.camel@sakura.staff.proxad.net>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
	 <20150522.150310.2248217318352290500.davem@davemloft.net>
	 <20150522192651.GA3629@breakpoint.cc>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.27.33.1] ([212.27.33.1]:50406 "EHLO ns.iliad.fr"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752603AbbEZKIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 06:08:22 -0400
In-Reply-To: <20150522192651.GA3629@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2015-05-22 at 21:26 +0200, Florian Westphal wrote:

Hello,

> But it does happen, see e.g. following bug report:
> http://marc.info/?l=linux-netdev&m=139870308431986&w=2
> 
> Maxime, do you recall what type of traffic generates
> the DF-fragments you reported?

Yep

We are an ISP and provide our own home gateway to the subscribers, which
ends up routing traffic of a large range of end user devices.

In that case, the frag+DF traffic was seen in an exchange between a
femtocell and a femto GW during the IPsec IKE exchange, more precisely
on the IKE_AUTH message sent from the femto GW.

You can contact me privately if you need more details.

-- 
Maxime

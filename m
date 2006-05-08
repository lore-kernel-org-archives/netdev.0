From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Mon, 08 May 2006 19:48:00 +0100
Message-ID: <1147114080.2885.164.camel@hades.cambridge.redhat.com>
References: <1146862832.2766.54.camel@pmac.infradead.org>
	 <20060506.091920.122414672.yoshfuji@linux-ipv6.org>
	 <1146876802.2503.32.camel@shinybook.infradead.org>
	 <20060506.113904.63157190.yoshfuji@linux-ipv6.org>
	 <1146926830.2503.67.camel@shinybook.infradead.org>
	 <445F7576.5080102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:8416 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751067AbWEHSrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 14:47:46 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <445F7576.5080102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-08 at 09:44 -0700, Rick Jones wrote:
> Or get the applications fixed no?  Kludging around application bugs 
> sounds a bit like the "Fram Oil Filter" commercial where the mechanic is 
> grinning while he says "You can pay me now, or you can pay be later." As 
> in pay for the slightly more expensive oil filter now, or engine repair 
> later.

Well, obviously. That's _why_ I want to deploy IPv6 and get it tested.
But I used to be able to do this without actually breaking the network,
and without being told to _stop_ running radvd because it breaks things.

> Other than fixing the applications that only take the first response 
> (isn't that a generic application bug going back nearly decades now? 
> amazing how things stay the same isn't it) Can you run a caching-only 
> name server at the edge that filters-out the IPv6 responses so your 
> systems never see Global IPV6 responses?

I don't think that kind of answer is going to be sufficient to persuade
Uli to switch back from favouring IPv4 over IPv6. That's done the trick,
admittedly -- by ensuring that we get _no_ testing of IPv6 unless we run
with IPv6-only networking :)

-- 
dwmw2


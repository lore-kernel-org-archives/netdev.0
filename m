From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netfilter: kernel panic with REDIRECT target. (2.6.23 and 2.6.23.8)
Date: Mon, 19 Nov 2007 22:31:43 +0300
Message-ID: <20071119193143.GA12640@2ka.mipt.ru>
References: <47408BBC.6040608@unsolicited.net> <200711182131.38388.ismail@pardus.org.tr> <474093E0.3090007@unsolicited.net> <47409863.8000902@trash.net> <4741DB3A.2030304@unsolicited.net> <20071119192423.GA26449@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Ismail =?utf8?Q?D=C3=B6nmez?= <ismail@pardus.org.tr>,
	netdev@vger.kernel.org
To: David <david@unsolicited.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41638 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbXKSTcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 14:32:08 -0500
Content-Disposition: inline
In-Reply-To: <20071119192423.GA26449@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 10:24:23PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Mon, Nov 19, 2007 at 06:51:38PM +0000, David (david@unsolicited.net) wrote:
> > Patrick McHardy wrote:
> > >>>>     iptables -t nat -A PREROUTING -j REDIRECT -i eth2 -p udp --dport
> > >>>> 5061 --to-ports 5060
> > >>>>
> > >>>>         
> > >>> Also post the kernel panic log.
> > >>>       
> > >
> > > Please try if this patch fixes the problem.
> > 
> > No luck with the patch I'm afraid, panic log attached (of patched kernel).
> 
> Ok, let's try it hard way.
> Please check attached patch and tell if it helped (it will produce
> some debug though).

With both patches applied - one Patrick showed and this one.

-- 
	Evgeniy Polyakov

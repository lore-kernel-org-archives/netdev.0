From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 04 Jul 2006 15:29:33 -0400
Message-ID: <1152041373.5276.36.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <449C06E3.3090406@trash.net>
	 <1151282720.4210.46.camel@ras.pc.brisbane.lube>
	 <449FC0AF.1050904@trash.net> <44A0CE01.4010109@stuart.id.au>
	 <44AA6D25.9000707@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>,
	Russell Stuart <russell@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:10413 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932348AbWGDT3g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 15:29:36 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fxqaa-000823-8w
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 15:29:40 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AA6D25.9000707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-07 at 15:29 +0200, Patrick McHardy wrote:
> Russell Stuart wrote:
[..]
> > Without seeing your actual proposal it is difficult to
> > judge whether this is a reasonable trade-off or not.
> > Hopefully we will see your code soon.  Do you have any
> > idea when?
> 
> Unfortunately I still didn't got to cleaning them up, so I'm sending
> them in their preliminary state. Its not much that is missing, but
> the netem usage of skb->cb needs to be integrated better, I failed
> to move it to the qdisc_skb_cb so far because of circular includes.
> But nothing unfixable. I'm mostly interested if the current size-tables
> can express what you need for ATM, I wasn't able to understand the
> big comment in tc_core.c in your patch.
> 

Looks good from within the range of "change within reason" of addressed
problem. The cb on the qdisc seems only usable for netem, correct?
Also while not unreasonable, i wasnt sure how qdisc_enqueue_root()
fit in the grand scheme of things for this change (it seemed out of
place).

cheers,
jamal


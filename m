From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: Re: WoL and r8169
Date: Wed, 10 Jun 2009 12:29:40 +0200
Message-ID: <20090610102940.87FE633C023@tippex.mynet.homeunix.org>
References: <20090607214220.5101B33C013@tippex.mynet.homeunix.org> <20090608215301.GA28044@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anders Eriksson <aeriksson@fastmail.fm>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp02.sth.basefarm.net ([80.76.149.213]:38869 "EHLO
	ch-smtp02.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751589AbZFJK34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 06:29:56 -0400
In-reply-to: <20090608215301.GA28044@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


romieu@fr.zoreil.com said:
> Anders Eriksson <aeriksson@fastmail.fm> : 
> [...]
>> Any insight in the appreciated.
> This one may be:
[...]
> --  Ueimor

Yes! That diff made the trick for WoL on magic package on my 2.6.30-rc6 kernel.
Is it sent to Linus for -final?

One additional thing. The card claims to support WoL on other traffic as well:
> Supports Wake-on: pumbg

I tried to wake up the machine using regular tcp traffic, on the theory that 
it's unicast and phy activity. No luck though.

What's the trick to wake up on tcp traffic? Or did I misread the man page?

/Anders


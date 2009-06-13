From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: Re: WoL and r8169
Date: Sat, 13 Jun 2009 16:19:40 +0200
Message-ID: <20090613141940.CE97933C0AC@tippex.mynet.homeunix.org>
References: <20090607214220.5101B33C013@tippex.mynet.homeunix.org> <20090608215301.GA28044@electric-eye.fr.zoreil.com> <20090610102940.87FE633C023@tippex.mynet.homeunix.org> <20090610230116.GA23440@electric-eye.fr.zoreil.com> <20090611111412.C908733C023@tippex.mynet.homeunix.org> <20090612225247.GA29698@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anders Eriksson <aeriksson@fastmail.fm>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:44250 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751113AbZFMOTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 10:19:55 -0400
In-reply-to: <20090612225247.GA29698@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


romieu@fr.zoreil.com said:
>> What's a magic tcp packet?

> As you said: a tcp packet which contains the magic sequence. 

The WoL tools I've found use UDP exclusively. What do you use to send a magic 
package using tcp?

I don't see the value of sending one with tcp, though. The tcp case _I_ am
looking for is to wake up on any tcp activity where the tcp session is used to
carry regular application data. 

-Anders



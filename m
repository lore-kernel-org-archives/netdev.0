From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 15:40:35 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191536100.3324@nehalem.linux-foundation.org>
References: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org> <20080819.142735.179034162.davem@davemloft.net> <alpine.LFD.1.10.0808191432040.3324@nehalem.linux-foundation.org> <20080819.144015.40311904.davem@davemloft.net>
 <alpine.LFD.1.10.0808191446560.3324@nehalem.linux-foundation.org> <20080819222612.GA16766@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43018 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbYHSWk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 18:40:56 -0400
In-Reply-To: <20080819222612.GA16766@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 20 Aug 2008, Evgeniy Polyakov wrote:
> 
> I belive it was you who told that there is no black and white (another 
> guy told that there is no spoon, I frequntly confuse).

Yes.

> Any changes made no matter when can not be 100% tested in laboratory 
> environment, even fixes, which look obviously.

100% agreed.

Please note that I'm not against these things slipping in occasionally. 
The reason I brought this up in the first place really wasn't the loopback 
driver issue at all. The reason I brought it up was simply the fact that 
when I compare the size and frequency of changes, the networking pulls 
tend to be the worst of the lot of the "core" kernel changes.

I say "core" kernel changes, because things are usually worse for the 
outliers. As mentioned, networking is actually one of the _better_ guys if 
you start comparing to the DVB people, or to some of the architectures 
that often slip the merge window _entirely_, and *all* their changes come 
in during -rc2 or something.

So it's not that networking is especially bad on an absolute scale in this 
regard. And it's not like it doesn't happen all the time for everybody 
else too. But I think networking has ben a bit more cavalier about things 
than many other core areas.

So no, I'm not asking for black-and-white absolutes here. But I'm asking 
for a "tightening of the belts". Please don't let it all hang out, ok?

			Linus

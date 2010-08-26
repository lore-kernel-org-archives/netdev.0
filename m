From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Thu, 26 Aug 2010 09:12:24 +0200
Message-ID: <4C7613D8.2040705@nets.rwth-aachen.de>
References: <1282630819-23104-1-git-send-email-hkchu@google.com> <1282632262.2378.1681.camel@edumazet-laptop> <4C737D15.5060400@nets.rwth-aachen.de> <423116d1d215b0fb3d1c966fb8167508@localhost> <4C73DE32.1030802@nets.rwth-aachen.de> <20100824162844.GA7889@nuttenaction> <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com> <cb32d2a8676d5447e04882302228c4b6@localhost> <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com> <20100825225942.GA3190@hell> <AANLkTik5N=j-2NQRFFktOs7gfDEU=Gdrva4fw6BKRqxT@mail.gmail.com> <3CD6E1F6-9143-43B9-A6D2-9B09F18C9C2E@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Eggert <lars.eggert@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slowhand.arndnet.de ([88.198.19.76]:44155 "EHLO mail.unitix.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751762Ab0HZHjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 03:39:37 -0400
In-Reply-To: <3CD6E1F6-9143-43B9-A6D2-9B09F18C9C2E@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lars,

Am 26.08.2010 08:01, schrieb Lars Eggert:
> On 2010-8-26, at 4:49, Jerry Chu wrote:
>   
>> Yes on a 2nd look RFC5482 seems more complex than I originally thought, allowing
>> many different combinations of local/adv/remote UTO... Are they really
>> useful, e.g.,
>> why allowing USER_TIMEOUT to be different from ADV_UTO?? My original thought
>> was the local UTO will always be the same as the one advertised to
>> remote so only
>> one API will be needed plus bunch of flags for ENABLED, CHANGEABLE...
>>     
>
> USER_TIMEOUT is what is locally used for a connection (i.e., takes into account what the remote peer advertised and what we'd like to use), while ADV_UTO is (only) what we'd like to use and are advertising.
>
> (Yes, we initially thought we could make the mechanism simpler, but then we started to think through all the corner cases...)
>   

But from the application point of view it is enough to request a
specific UTO
as a socket option, (which will then get announced via ADV_UTO), right?
Is there any reason, (besides local policy) to not abort the connection
locally
after the time the application specified via the above mentioned socket
option?


Best regards,
Arnd

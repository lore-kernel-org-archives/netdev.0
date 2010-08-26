From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] =?UTF-8?Q?TCP=5FFAILFAST=3A=20a=20new=20socket=20opti?=  =?UTF-8?Q?on=20to=20timeout/abort=20a=20connection=20quicker?=
Date: Thu, 26 Aug 2010 09:42:36 +0200
Message-ID: <721573f62ad1c200e14e446297ebefed@localhost>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
 <423116d1d215b0fb3d1c966fb8167508@localhost>
 <4C73DE32.1030802@nets.rwth-aachen.de> <20100824162844.GA7889@nuttenaction>
 <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
 <cb32d2a8676d5447e04882302228c4b6@localhost>
 <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
 <20100825225942.GA3190@hell>
 <AANLkTik5N=j-2NQRFFktOs7gfDEU=Gdrva4fw6BKRqxT@mail.gmail.com>
 <3CD6E1F6-9143-43B9-A6D2-9B09F18C9C2E@nokia.com>
 <4C7613D8.2040705@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lars Eggert <lars.eggert@nokia.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<ilpo.jarvinen@helsinki.fi>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:58147 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752323Ab0HZHmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 03:42:38 -0400
In-Reply-To: <4C7613D8.2040705@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 26 Aug 2010 09:12:24 +0200, Arnd Hannemann wrote:



>> USER_TIMEOUT is what is locally used for a connection (i.e., takes into

>> account what the remote peer advertised and what we'd like to use),

while

>> ADV_UTO is (only) what we'd like to use and are advertising.

>>

>> (Yes, we initially thought we could make the mechanism simpler, but

then

>> we started to think through all the corner cases...)

>>   

> 

> But from the application point of view it is enough to request a

> specific UTO

> as a socket option, (which will then get announced via ADV_UTO), right?

> Is there any reason, (besides local policy) to not abort the connection

> locally

> after the time the application specified via the above mentioned socket

> option?



The original USER_TIMEOUT (RFC 793) functionality boils down to Jerry's

TCP_FAILFAST patch. This _per see_ has no correlation with the ADV_UTO.

Likely that the ADV_UTO will update the USER_TIMEOUT too. I change my

position from day to day: artificially limit the mechanism and provide a

per see "clever" mechanism and keep both values coherent or provide all

freedom to the user.



Hagen

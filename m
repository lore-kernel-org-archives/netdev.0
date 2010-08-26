From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] =?UTF-8?Q?TCP=5FFAILFAST=3A=20a=20new=20socket=20opti?=  =?UTF-8?Q?on=20to=20timeout/abort=20a=20=20connection=20quicker?=
Date: Thu, 26 Aug 2010 09:27:40 +0200
Message-ID: <2a2565dca444fd26e88bb822ae9c3cf4@localhost>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
 <423116d1d215b0fb3d1c966fb8167508@localhost>
 "<4C73DE32.1030802@nets.rwth-aachen.de>"
 <20100824162844.GA7889@nuttenaction>
 <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
 <cb32d2a8676d5447e04882302228c4b6@localhost>
 <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
 <20100825225942.GA3190@hell>
 <AANLkTik5N=j-2NQRFFktOs7gfDEU=Gdrva4fw6BKRqxT@mail.gmail.com>
 <3CD6E1F6-9143-43B9-A6D2-9B09F18C9C2E@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<ilpo.jarvinen@helsinki.fi>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Lars Eggert <lars.eggert@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:51666 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752825Ab0HZH1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 03:27:41 -0400
In-Reply-To: <3CD6E1F6-9143-43B9-A6D2-9B09F18C9C2E@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 26 Aug 2010 09:01:31 +0300, Lars Eggert wrote:



Hi Jerry, Hi Lars



> USER_TIMEOUT is what is locally used for a connection (i.e., takes into

> account what the remote peer advertised and what we'd like to use),

while

> ADV_UTO is (only) what we'd like to use and are advertising.

> 

> (Yes, we initially thought we could make the mechanism simpler, but then

> we started to think through all the corner cases...)



o TCP_USER_TIMEOUT for the local timeout seems fine. This is consistent

with the literature and everybody knows how to interpret such a variable.



o TCP_ADV_UTO for the announced timeout. It correspond with the RFC and

inherent the word "advertise".



Jerry, for you the former is of interest, you can completely ignore my

on-top-functionality. I am satisfied with this!



Cheers, Hagen

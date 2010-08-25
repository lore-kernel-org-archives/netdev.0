From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] =?UTF-8?Q?TCP=5FFAILFAST=3A=20a=20new=20socket=20opti?=  =?UTF-8?Q?on=20to=20timeout/abort=20a=20connection=20quicker?=
Date: Wed, 25 Aug 2010 10:21:39 +0200
Message-ID: <cb32d2a8676d5447e04882302228c4b6@localhost>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
 <423116d1d215b0fb3d1c966fb8167508@localhost>
 <4C73DE32.1030802@nets.rwth-aachen.de> <20100824162844.GA7889@nuttenaction>
 <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<ilpo.jarvinen@helsinki.fi>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:43575 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751838Ab0HYIVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 04:21:46 -0400
In-Reply-To: <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 24 Aug 2010 15:13:44 -0700, Jerry Chu <hkchu@google.com> wrote:

> On Tue, Aug 24, 2010 at 9:28 AM, Hagen Paul Pfeifer <hagen@jauu.net>

wrote:



> So it looks like the user timeout can be used in either senario

(shortening

> or lengthening) and in both cases is a lower bound, i.e., the connection

> should abort at or shortly after the specified user timeout.

>

> In this case does it make sense to combine the two? Will your TCP_UTO

> patch be ready anytime soon?

> 

> Again an alternative is to allow configuring tcp_retries2 and

TCP_RTO_MAX

> directly. I'm open to suggestion but we'd like to get something in

sooner.



Hello Chu! My Idea: you provide functionality to modify the user timeout.

The interface should be generic enough to allow small as well as large - up

to 22 days - values. This interface should be sufficient for you and later

for me. Afterwards I provide an patch which apply on your groundwork. My

patch handle TCP UTO specific functionality like TCP option protocol

handling functionality, socket option, permissions, lower- and upper

bounds, ...



Did you check interactions with other TCP timers like keep-alive timer? 



Today in the evening I will focus on TCP Quick ACK modifications. After

that I am in the Alps for vacation for 5 days. Later on I will work on the

patch (the patch is in a good state, modification and testing should

consume only 2 evenings - hopefully ;-).



Cherry, is this ok for you?



Hagen

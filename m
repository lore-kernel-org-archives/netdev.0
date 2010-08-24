From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] =?UTF-8?Q?TCP=5FFAILFAST=3A=20a=20new=20socket=20opti?=  =?UTF-8?Q?on=20to=20timeout/abort=20a=20connection=20quicker?=
Date: Tue, 24 Aug 2010 11:10:44 +0200
Message-ID: <423116d1d215b0fb3d1c966fb8167508@localhost>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"H.K. Jerry Chu" <hkchu@google.com>, <ilpo.jarvinen@helsinki.fi>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37676 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751805Ab0HXJKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 05:10:45 -0400
In-Reply-To: <4C737D15.5060400@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 24 Aug 2010 10:04:37 +0200, Arnd Hannemann wrote:



> Why not call it TCP_USERTIMEOUT?

> Later you can also send it via the TCP user timeout option... (RFC5482)

> Hmm... is the ms granularity really needed? Does it make sense to abort

> a connection below a second?



I am working on a patch for UTO, the lion share is already implemented. As

I can see this patch introduce a upper limit (max) where UTO on the other

hand provides a lower limit (min). Therefore I am not sure if we should

call this option TCP_USERTIMEOUT.



Cheers, Hagen

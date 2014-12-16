From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net: integer overflow in ip_idents_reserve
Date: Wed, 17 Dec 2014 00:09:16 +0100
Message-ID: <1418771356.3449499.203748285.4B1A82B8@webmail.messagingengine.com>
References: <5490A1F8.6020207@oracle.com>
 <1418766460.9773.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrey Ryabinin <a.ryabinin@samsung.com>,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55276 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013AbaLPXJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 18:09:18 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id DEAE720BDD
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 18:09:16 -0500 (EST)
In-Reply-To: <1418766460.9773.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Dec 16, 2014, at 22:47, Eric Dumazet wrote:
> On Tue, 2014-12-16 at 16:19 -0500, Sasha Levin wrote:
> > Hi Eric,
> > 
> > While fuzzing with trinity on a -next kernel with the undefined behaviour
> > sanitizer path, I've observed the following warning in code which was
> > introduced in 04ca6973f7 ("ip: make IP identifiers less predictable"):
> 
> This is a false positive.

Also we compile the whole kernel with -fno-strict-overflow, so every
report of signed overflow leading to undefined behavior is probably a
false positive. I don't know if it is worth to try to get rid of them, I
doubt it.

Bye,
Hannes

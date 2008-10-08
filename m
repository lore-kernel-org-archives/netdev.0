From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible regression in HTB
Date: Wed, 08 Oct 2008 02:40:48 +0200
Message-ID: <48EC0190.7040804@trash.net>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64521 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbYJHAmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:42:19 -0400
In-Reply-To: <48EBFF5E.1090902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> So what would really be useful to understand this is to make HTB
> control the queue and see if it behaves as expected. 

What also might help understand this better would be some
runtime data. An easy way to get some halfway usable data
is to just run

tc -s -d qdisc show dev ...; tc -s -d class show dev ...

in a loop.

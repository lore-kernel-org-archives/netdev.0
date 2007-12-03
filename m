From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Mon, 03 Dec 2007 08:45:39 +0100
Message-ID: <4753B423.7030000@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill> <474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57286 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbXLCHpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 02:45:53 -0500
In-Reply-To: <47503971.9080509@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
> Thanks for your comments!
> 
> I'd like to better understand your dislike of the current implementation 
>  of the data transfer from user space to kernel space.
> Is it the fact that we use configfs?
> I think, we had already a discussion about this (and we changed from 
> procfs to configfs).
> Or don't you like that we need a user space daemon which is responsible 
> for feeding the data to the kernel module?
> I think we do not have another option, since the trace file may be of 
> arbitrary length.
> Or anything else?


I dislike using anything besides rtnetlink for qdisc configuration.
The only way to transfer arbitary amounts of data over netlink would
be to spread the data over multiple messages. But then again, you're
using kmalloc and only seem to allocate 4k, so how large are these
traces in practice?


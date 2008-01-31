From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:01:00 +0100
Message-ID: <47A20CDC.5090104@trash.net>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55230 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453AbYAaSBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:01:05 -0500
In-Reply-To: <20080131183322.GA4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> Fix the broken qdisc instead.
> 
> What do you mean? I don't think the qdiscs are broken.
> I cannot think of any way how e.g. TBF can do anything useful
> with large TSO packets.


Someone posted a patch some time ago to calculate the amount
of tokens needed in max_size portions and use that, but IMO
people should just configure TBF with the proper MTU for TSO.


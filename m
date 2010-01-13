From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per interface
Date: Wed, 13 Jan 2010 08:57:07 -0500
Message-ID: <x49ljg25cr0.fsf@segfault.boston.devel.redhat.com>
References: <4B4630C0.6090206@gmail.com> <4B467A4D.9070708@gmail.com>
	<1263252108.29868.4774.camel@calx>
	<20100111.155912.68138954.davem@davemloft.net>
	<1263254625.29868.4777.camel@calx> <4B4BBDA5.8010808@gmail.com>
	<4B4D1372.9060702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev@oss.sgi.com
To: Daniel Borkmann <danborkmann@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab0AMN5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 08:57:15 -0500
In-Reply-To: <4B4D1372.9060702@gmail.com> (Daniel Borkmann's message of "Wed,
	13 Jan 2010 01:27:30 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <danborkmann@googlemail.com> writes:

> Daniel Borkmann wrote:
>> Matt Mackall wrote:
>>> On Mon, 2010-01-11 at 15:59 -0800, David Miller wrote:
>>>> From: Matt Mackall <mpm@selenic.com>
>>>> Date: Mon, 11 Jan 2010 17:21:48 -0600
>>>>
>>>>> Looks pretty good. Dave?
>>>>>
>>>>> Acked-by: Matt Mackall <mpm@selenic.com>
>>>> I don't like the loop for RX ARP processing.
>>>>
>>>> The packet contents aren't going to change, so doing basic
>>>> packet validation inside of the "for each RX client" loop
>>>> of arp_reply() doesn't make any sense.
>>> True. Dan, please help our poor compilers with some manual loop
>>> invariant motion.
>> 
>> Okay, true. I'll fix this by tomorrow and resend the patch.
>
> Here the fix of the RX ARP processing routine. Content that isn't
> going to change is out-of-loop.
> Successfully tested on my machines.

Against what tree does this patch apply?  It doesn't apply to Linus's
git tree.  Also, in the future, could you use the -p option to diff so
we can see what function or data structure is being modified?  It really
helps in reviewing.

Thanks!
Jeff

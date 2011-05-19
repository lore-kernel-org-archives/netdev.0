From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 20:52:49 +0200
Message-ID: <4DD56701.8040007@neli.hopto.org>
References: <4DD36803.1020001@neli.hopto.org>	 <20110518.023725.441358922110721042.davem@davemloft.net>	 <4DD36E54.9040706@neli.hopto.org>	 <20110518.181427.1228926976939865196.davem@davemloft.net> <1305819120.3271.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.172]:20421 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933792Ab1ESSxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 14:53:24 -0400
In-Reply-To: <1305819120.3271.3.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> On Wed, 2011-05-18 at 18:14 -0400, David Miller wrote:
>> Please fix ic_is_init_dev() to return a proper boolean "false" instead
>> of "0" when IFF_LOOPBACK is set.

Ok. Had an int before, but boolean is better.

> Shouldn't the code still wait at *least* one second?  Not all drivers
> support carrier detect, and those that don't set the carrier always-on.
> Thus older devices that used to have 1s to get carrier in line (even if
> they don't report it) now have only 10ms.
> 
> I think it should wait at least one second like the code currently does,
> and then if the carrier still isn't up, wait longer.

What is the 1 second based on?

If a driver does not support carrier detect, then this code will wait
for the timeout period. Or do those older drivers set carrier detect
immediately when device is probed?

Micha

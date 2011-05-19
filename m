From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 15:19:45 -0400 (EDT)
Message-ID: <20110519.151945.60111725625001721.davem@davemloft.net>
References: <4DD36E54.9040706@neli.hopto.org>
	<20110518.181427.1228926976939865196.davem@davemloft.net>
	<1305819120.3271.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: micha@neli.hopto.org, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757098Ab1ESTTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:19:53 -0400
In-Reply-To: <1305819120.3271.3.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Thu, 19 May 2011 10:31:58 -0500

> On Wed, 2011-05-18 at 18:14 -0400, David Miller wrote:
>> From: Micha Nelissen <micha@neli.hopto.org>
>> Date: Wed, 18 May 2011 08:59:32 +0200
>> 
>> > Op 2011-05-18 8:37, David Miller schreef:
>> >> From: Micha Nelissen<micha@neli.hopto.org>
>> >> Date: Wed, 18 May 2011 08:32:35 +0200
>> >>
>> >>> I'm confused. Against which tree/commit do you want it then?
>> >>
>> >> Linus's current tree would be fine as would:
>> >>
>> >> 	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>> > 
>> > Ok I see, thanks. The patch should apply just fine to your tree, there
>> > is only a spelling change since 2.6.38 which does not conflict.
>> 
>> Please fix ic_is_init_dev() to return a proper boolean "false" instead
>> of "0" when IFF_LOOPBACK is set.
> 
> Shouldn't the code still wait at *least* one second?  Not all drivers
> support carrier detect, and those that don't set the carrier always-on.
> Thus older devices that used to have 1s to get carrier in line (even if
> they don't report it) now have only 10ms.
> 
> I think it should wait at least one second like the code currently does,
> and then if the carrier still isn't up, wait longer.

Agreed.

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Sat, 01 Dec 2012 12:02:57 -0500
Message-ID: <201212011702.qB1H2v07010546@thirdoffive.cmf.nrl.navy.mil>
References: <1354380532.21562.345.camel@shinybook.infradead.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	krzysiek@podlesie.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:40161 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab2LARDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 12:03:13 -0500
In-reply-to: <1354380532.21562.345.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1354380532.21562.345.camel@shinybook.infradead.org>,David Woodhouse writes:
>On Sat, 2012-12-01 at 11:44 -0500, David Miller wrote:
>> It's from adding the completion to the solos skb cb, you can't do
>> that.  It won't fit on 64-bit when all debugging kconfig options are
>> enabled.
>
>Aha, thanks. Will sort that out. Apologies.
>
>The ambassador one may be related to a separate patch which fixes the
>endless loop in firmware loading? Not in my tree, though.

i think the warning with the ambassador dates back to before the most
recent patch.  probably to the conversion to use the firmware loader.

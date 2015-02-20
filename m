From: David Miller <davem@davemloft.net>
Subject: Re: Altera TSE (altera_tse) - tx_fifo_depth init bug
Date: Fri, 20 Feb 2015 15:17:22 -0500 (EST)
Message-ID: <20150220.151722.167446633406590850.davem@davemloft.net>
References: <54C8026B.9070607@vsis.cz>
	<20150129.142250.2177840872104162590.davem@davemloft.net>
	<54E27283.3020201@vsis.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridger@opensource.altera.com
To: setka@vsis.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbbBTURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:17:24 -0500
In-Reply-To: <54E27283.3020201@vsis.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlastimil Setka <setka@vsis.cz>
Date: Mon, 16 Feb 2015 23:43:15 +0100

>> Your patch was corrupted by your email client, in particular TAB
>> characters were transformed into a series of SPACE characters.
> 
> Hello,
> sorry for inconvenience, here is a correct patch:

This is not the correct way to submit a patch.

You should never provide a patch for us to apply as a reply to another
email.

Instead you should always make a fresh, new, mailing list posting.

Your Subject line and message body should contain only the exact
text you want to appear in the commit message.  You should not
include things like "Hello, " or other trivialities that would
need to be edited out.

Also, your Subject line should be of the form:

	$subsystem: $description

Where subsystem is the most specific name of the area you're
changing, in lowercase letters.

You should not use multi-word sequences as you have to state
the subsystem.  Simply "altera_tse: " is completely sufficient.

The most annoying thing about seeing the errors you are making is that
if you simply mimicked at how other driver maintainers arrange their
subject lines and message bodies, you would end up doing the right
thing.

Use what other people do as a guide, and don't try to do things in
a special or unique way.

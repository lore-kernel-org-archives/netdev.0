From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] bridge: assign random address
Date: Mon, 17 Dec 2007 20:09:57 -0500
Message-ID: <47671DE5.3010605@garzik.org>
References: <20071216142915.c120d25c.akpm@linux-foundation.org>	<20071216.152606.35263254.davem@davemloft.net>	<4765D4F0.5040202@garzik.org> <20071216.202443.251372179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berrange@redhat.com, herbert@gondor.apana.org.au, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42138 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbXLRBKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:10:06 -0500
In-Reply-To: <20071216.202443.251372179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Sun, 16 Dec 2007 20:46:24 -0500
> 
>> David Miller wrote:
>>> [Patch 1/7] [SUBSYSTEM]: Foo bar baz...
>> The most popular tool is git-am, which I and many others use.
>>
>> git-am will snip "[SUBSYSTEM]" in the example that you give.
> 
> It should only snip the first "[Patch X/Y] " part, or the manual is
> buggy :-)

Manual is buggy.

	[jgarzik@pretzel netdev-2.6]$ grep '^Subject:' /g/tmp/mbox
	Subject: [PATCH 1/2][FOO][BAR][BAZ] tulip: napi full quantum bug

is merged as

	commit e34e20a3ae1ec30856427d260f454b8984ebced2
	Author: Stephen Hemminger <shemminger@linux-foundation.org>
	Date:   Thu Dec 13 09:35:45 2007 -0800

	    tulip: napi full quantum bug

And that matches existing practice, where people put tons of 
not-to-be-merged metadata into the subject lines.

Regards,

	Jeff



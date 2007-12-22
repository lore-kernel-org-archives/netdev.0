From: Joe Perches <joe@perches.com>
Subject: Re: [ETH]: Combine format_addr() with print_mac().
Date: Fri, 21 Dec 2007 23:02:45 -0800
Message-ID: <1198306965.4895.5.camel@localhost>
References: <1198274738.5578.2.camel@dell>
	 <1198276619.18877.42.camel@localhost>  <1198295882.6752.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, anilgv@broadcom.com,
	michaelc@cs.wisc.edu, david.somayajulu@qlogic.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3079 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbXLVHCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2007 02:02:51 -0500
In-Reply-To: <1198295882.6752.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-21 at 19:58 -0800, Michael Chan wrote:
> The dev_addr is declared as unsigned char* in struct net_device.  To be
> consistent, can we change print_mac() and MAC_BUF to use unsigned char*?
> They are really the same.

That's fine by me.  I like consistency.
I don't remember why it was u8 and not unsigned char.

> > ssize_t? shouldn't it be size_t?
> I'm just keeping the prototype unchanged as originally defined in net-
> sysfs.c

It's painless to change the prototype.
size_t seems more sensible.

> > Indexing buf by int len is unchecked.
> > That could lead to unintended buffer overruns.
> > Maybe add a buflen argument and use snprintf?
> Again, I kept the semantics the same as the original, but will be happy
> to add a buflen for better checking.

That sounds good.

cheers, Joe


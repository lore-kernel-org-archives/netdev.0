From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6 PATCH] net: Move && and || to end of
 previous line
Date: Mon, 30 Nov 2009 09:57:15 -0800
Message-ID: <1259603835.29779.295.camel@Joe-Laptop.home>
References: <1259001504.16503.79.camel@Joe-Laptop.home>
	 <20091123.104130.117837098.davem@davemloft.net>
	 <1259528449.29779.194.camel@Joe-Laptop.home>
	 <20091129.165557.84377714.davem@davemloft.net>
	 <20091130092837.4998f961@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1194 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbZK3R5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 12:57:09 -0500
In-Reply-To: <20091130092837.4998f961@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-30 at 09:28 -0800, Stephen Hemminger wrote:
> Rather than playing with the dangling operator format which seems to be a coding
> style that only David cares about. Why not go through and fix the really ugly old
> drivers that need it.

net/... had the lower percentage of leading uses
and a maintainer that cared to standardize.

drivers/... has many odd uses of coding styles and
no single maintainer that cares much about style.

> For a good horror experience, go look at the floppy driver.

I've no desire to be floppy maintainer.  Do you?

$ ./scripts/get_maintainer --nogit -f driver/block/floppy.c
linux-kernel@vger.kernel.org




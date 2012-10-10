From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 07:41:59 -0700
Message-ID: <1349880119.2386.46.camel@joe-AO722>
References: <20121010093816.GA3669@elgon.mountain>
	 <1349864358.2386.27.camel@joe-AO722> <m21uh67csy.fsf@igel.home>
	 <1349874007.2386.42.camel@joe-AO722> <m2sj9m5sz5.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48660 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932217Ab2JJOmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 10:42:00 -0400
In-Reply-To: <m2sj9m5sz5.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 15:58 +0200, Andreas Schwab wrote:
> Sorry, I was misremembering the history of the bit ops.  There has
> historically been issues with varying bit order, but noadays set_bit is
> always defined consistently with C shifts.

No worries.  Anyway, the change was suggested to aid
reader comprehension.  If it doesn't (and it seems not)
then it's not worth it.

Anyway, there is still the open question of an overrun/info
leak.

> > -           if ((r = set_arg(argp, protos, 8 * sizeof(long))))

set_arg's 2nd arg is bytes not bits.

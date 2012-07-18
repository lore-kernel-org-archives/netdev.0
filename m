From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ISDN] Add check for usb_alloc_urb() result
Date: Wed, 18 Jul 2012 09:44:44 -0700 (PDT)
Message-ID: <20120718.094444.1720284949125788005.davem@davemloft.net>
References: <1342169986-24268-1-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rucsoftsec@gmail.com, m.bachem@gmx.de
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab2GRQop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:44:45 -0400
In-Reply-To: <1342169986-24268-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Fri, 13 Jul 2012 10:59:46 +0200

> usb_alloc_urb() return value needs to be checked to avoid
> later NULL pointer access.
> Reported by rucsoftsec@gmail.com via bugzilla.kernel.org #44601.
> 
> Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>

Applied.

Please use consistent subject line formatting.  In your previous
patch you provided:

	[PATCH] ISDN:foo bar baz

which I corrected to:

	[PATCH] ISDN: foo bar baz

And for this patch you provided:

	[PATCH ISDN] foo bar baz

which I corrected to:

	[PATCH] ISDN: foo bar baz

Anything in those initial brackets will be removed by the
automated GIT tools, it's a place for text strings you don't
want to end up in the final commit message.

But you want that "ISDN: " prefix there in the end, so please
do not put it in brackets, and please do put a space after
that ":"

Thanks.

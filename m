From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Fri, 04 Sep 2009 20:32:19 -0700 (PDT)
Message-ID: <20090904.203219.24187379.davem@davemloft.net>
References: <4AA1B712.6060900@hp.com>
	<1252112881.27694.3.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934540AbZIEDcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 23:32:03 -0400
In-Reply-To: <1252112881.27694.3.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 05 Sep 2009 03:08:01 +0200

> can we please add the err = -E... where it actually is needed and not
> stupidly go ahead and silence compiler warnings with err = 0. This has
> been posted before.

Ummm, no.  Actually Brian's patch is correct.

I can't even prove that there are no paths where err won't
be initialized properly to something.

And if such an occurance happens, returning "0" is absolutely
the right thing to do.

And that's what Brian's patch does.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Wed, 12 Jan 2011 18:47:34 -0800 (PST)
Message-ID: <20110112.184734.38051229.davem@davemloft.net>
References: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, opurdila@ixiacom.com, ddvlad@rosedu.org
To: lucian.grijincu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932736Ab1AMCrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 21:47:01 -0500
In-Reply-To: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Wed, 12 Jan 2011 12:19:10 +0200

> The IPV4_DEVCONF_* enums are never exposed to the userspace and it
> would make code simpler to remove all the useless (-1) adjustments.

Starting values like this at "1" is usually done on purpose.

It allows "0" to be illegal or mean "none", and thus easily trapping
cases where the value fails to be initialized properly.  In this way
the illegal sentinel "0" doesn't take up any space either.

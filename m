From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Tue, 15 Oct 2013 16:14:30 -0700 (PDT)
Message-ID: <20131015.161430.1205081387240695870.davem@davemloft.net>
References: <20131010063301.GO7660@secunet.com>
	<20131011.150124.527914076255487526.davem@davemloft.net>
	<20131015073020.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933597Ab3JOXHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 19:07:31 -0400
In-Reply-To: <20131015073020.GV7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 15 Oct 2013 09:30:20 +0200

> We could fiddle something to get a terminating condition if the
> state is not resolved after some time, but my plan was to disable
> the larval_drop sysctl by default some day again. At best without
> any notable change to userspace. That's why I would prefer to
> remove the sleeping entirely.

Ok I have no problem with removing the sleeping stuff.

From: David Miller <davem@davemloft.net>
Subject: Re: qdisc hash table changes...
Date: Tue, 09 Aug 2016 01:54:17 -0700 (PDT)
Message-ID: <20160809.015417.214949723922909511.davem@davemloft.net>
References: <20160808.155335.2122819330212870390.davem@davemloft.net>
	<alpine.LNX.2.00.1608090936180.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jikos@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35166 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbcHIIyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 04:54:23 -0400
Received: by mail-pf0-f175.google.com with SMTP id x72so3171359pfd.2
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 01:54:22 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.00.1608090936180.22028@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jikos@kernel.org>
Date: Tue, 9 Aug 2016 09:42:01 +0200 (CEST)

> It does indirectly pull in some networking headers, but it doesn't pull in 
> netdevice.h (which is the place where the actual include of hashtable.h 
> happens):

It pulls in skbuff.h, so are you willing to bet forever that skbuff.h
won't indirectly pull in netdevice.h at some point in the future?

This is obviously a big problem, having global namespace conflicts
like this.

Pushing fixing it propering into the future isn't really the right
thing to do.

So please entertain my request to do this properly.

Thank you.

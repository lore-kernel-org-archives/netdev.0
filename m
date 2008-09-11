From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Thu, 11 Sep 2008 16:01:17 -0700 (PDT)
Message-ID: <20080911.160117.118147467.davem@davemloft.net>
References: <20080911165913.GA27725@xw6200.broadcom.net>
	<20080911.145154.112457696.davem@davemloft.net>
	<1221173758.12785.32.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbYIKXBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 19:01:23 -0400
In-Reply-To: <1221173758.12785.32.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 11 Sep 2008 15:55:58 -0700

> Send BD corruption is quite serious as it can cause tg3_tx() to crash.
> We've seen a number of similar crashes over the years caused by
> re-ordered IOs and the nr_frags getting modified by HTB.
> 
> Since regression/security/oops fixes are allowed, shouldn't this qualify
> since it prevents a crash in tg3_tx()?

It's at best borderline, since tg3_tx() has reordering detection logic
which will reset and recover the card.

Until I see a real user trigger this I'm still leaning towards no.

Otherwise any driver maintainer can give me this spiel to get their
changes installed outside of the merge window, and that subverts the
entire purpose of the rules.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/21][next] qlge: Clean up and add firmware support.
Date: Sun, 25 Jan 2009 22:17:53 -0800 (PST)
Message-ID: <20090125.221753.112625253.davem@davemloft.net>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53739
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754174AbZAZGRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 01:17:51 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri, 23 Jan 2009 07:15:13 -0800

> 1) Adds in device ID 8000.  Note that it replaces 8012. We don't want to
> carry forward 8012 support unless forced to. If necessary we'll add it
> in disto. It was an early device that didn't have firmware support and
> different flash layout.

You can't add a driver for a device and then say later:
"Oh well, we don't feel like supporting that any longer"

And yes that even applies for something added as recently as September
2008 as this one was.

This leaves a very bad taste in my mouth and that's just the first
patch in the series :-/

You had other changes in the feedback given to you so please undo this
drop of 0x8000 support and respin the rest of the patches too.

I'm completely dropping this series.

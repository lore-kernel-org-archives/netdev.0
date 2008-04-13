From: David Miller <davem@davemloft.net>
Subject: Re: Reporting bugs and bisection
Date: Sun, 13 Apr 2008 13:35:46 -0700 (PDT)
Message-ID: <20080413.133546.43018013.davem@davemloft.net>
References: <20080413184730.GD8474@1wt.eu>
	<20080413121831.d89dd424.akpm@linux-foundation.org>
	<20080413202118.GA29658@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, w@1wt.eu, rjw@sisk.pl, tilman@imap.cc,
	Valdis.Kletnieks@vt.edu, lkml@rtr.ca, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752637AbYDMUfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 16:35:45 -0400
In-Reply-To: <20080413202118.GA29658@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 14 Apr 2008 00:21:18 +0400

> If the same would be done on developers machine and huge patches would
> be sent to jump between changesets, that would be a real 'work closely
> with the reporter working out why the reporter's failure was occurring'?

In fact, this is what Andrew's so-called "back and forth with the bug
reporter" used to mainly consist of.  Asking the user to try this patch or
that patch, which most of the time were reverts of suspect changes.

Which, surprise surprise, means we were spending lots of time
bisecting things by hand.

We're able to automate this now and it's not a bad thing.

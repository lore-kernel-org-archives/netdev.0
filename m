From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sat, 12 Apr 2008 02:49:52 -0700 (PDT)
Message-ID: <20080412.024952.151646629.davem@davemloft.net>
References: <20080411151821.GA32398@2ka.mipt.ru>
	<20080411.110702.146231359.davem@davemloft.net>
	<20080412084400.GA30259@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, lkml@rtr.ca, ilpo.jarvinen@helsinki.fi,
	jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757747AbYDLJtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 05:49:52 -0400
In-Reply-To: <20080412084400.GA30259@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sat, 12 Apr 2008 10:44:00 +0200

> While it is a powerful tool, we must accept that it cannot efficiently
> work in some circumstances, such as :

Everyone is well aware of all of this, that's why I specifically asked
for a bisect, because I knew it would be crucial to pinpointing this
particular bug.

And lo' and behold in 15 minutes after the bisect results were
available it got fixed.

Yes it takes judgment, and nobody ever suggested that a revert
is the way to go.  Git bisect results must be parsed by a human
brain.  Nothing else was ever implied in any way shape or form.

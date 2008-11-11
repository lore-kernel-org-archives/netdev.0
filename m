From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Tue, 11 Nov 2008 15:50:41 -0800 (PST)
Message-ID: <20081111.155041.90523159.davem@davemloft.net>
References: <1225809909.10206.90.camel@localhost.localdomain>
	<4919DAB4.7050009@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbYKKXul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 18:50:41 -0500
In-Reply-To: <4919DAB4.7050009@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Tue, 11 Nov 2008 20:19:16 +0100

> Not that it solves the problem, but it looks awfully much like this problem I reported 6 months back on the niu-driver just using a 10GbitE card.
> 
> http://article.gmane.org/gmane.linux.kernel/677545/match=niu
> 
> I shifted to a binary driver i got from Matheos Worku and that
> hasn't blown up since. (I expect that can rule out hardware problems).

Since I've never seen this behavior myself (and neither have people
doing very high log routing tests with these cards, such as Robert
Olsson) I plan to start putting together some debugging patches for
analyzing this TX hang.

If you could run those test patches when I post them and give
the log messages they produce, I'd appreciate it.

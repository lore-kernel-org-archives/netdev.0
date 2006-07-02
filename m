From: Jan Knutar <jk-lkml@sci.fi>
Subject: Re: 2.6.17: networking bug??
Date: Sun, 2 Jul 2006 20:39:06 +0300
Message-ID: <200607022039.06166.jk-lkml@sci.fi>
References: <448EC6F3.3060002@rtr.ca> <448EF45B.2080601@rtr.ca> <448EF85E.50405@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <lkml@rtr.ca>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw03.mail.saunalahti.fi ([195.197.172.111]:46526 "EHLO
	gw03.mail.saunalahti.fi") by vger.kernel.org with ESMTP
	id S1751387AbWGBRjh (ORCPT <rfc822;<netdev@vger.kernel.org>>);
	Sun, 2 Jul 2006 13:39:37 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <448EF85E.50405@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 June 2006 20:39, John Heffner wrote:

> The best thing you can do is try to find this broken box and inform its 
> owner that it needs to be fixed.  (If you can find out what it is, I'd 
> be interested to know.)  In the meantime, disabling window scaling will 
> work around the problem for you.

I was bit by this "networking bug" too. The broken box turned out to be
the OpenBSD box I was trying to connect to.

The owner removed scrub from pf.conf, and connectivity was restored.

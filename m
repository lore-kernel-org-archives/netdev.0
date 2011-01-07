From: David Brownell <david-b@pacbell.net>
Subject: Re: rndis gadget: Inconsistent locking
Date: Fri, 7 Jan 2011 03:20:29 -0800 (PST)
Message-ID: <113676.26138.qm@web180310.mail.gq1.yahoo.com>
References: <AANLkTi=OS+jernOe8y1fbMbx5Rf+JRcvzqGY4Z2LKqsH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Neil Jones <neiljay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm29.bullet.mail.sp2.yahoo.com ([98.139.91.99]:40705 "HELO
	nm29.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751728Ab1AGLUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 06:20:32 -0500
In-Reply-To: <AANLkTi=OS+jernOe8y1fbMbx5Rf+JRcvzqGY4Z2LKqsH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Yes Michal Nazarewicz has seen this on a S3C UDC, 

Good to confirm that.  As I mentioned, other folk have seen much the same bug on other hardware; we
know it's neither a new nor a HW-specific issue.

Correction to an earlier comment of mine: 

https://patchwork.kernel.org/patch/195562/
does correctly identify the commit which
caused this bug in multiple drivers.

However, that patch won't apply to the latest
tree from Linus.

Michal, can you update and resubmit, so I can
at least ack your fix and xpedite its merge?

It'd be good  to have RNDIS work again, a fair
number of folk rely on it, and this seems to be
the main obstacle to continuing to do that.


- Dave






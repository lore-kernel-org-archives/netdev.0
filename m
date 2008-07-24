From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 10:35:26 +0200
Message-ID: <20080724083526.GA10297@elte.hu>
References: <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com> <20080722135723.GA23077@elte.hu> <4885F496.3010305@davidnewall.com> <20080722153443.GB18757@elte.hu> <20080722211256.GB29189@1wt.eu> <20080723082643.GA992@elte.hu> <20080724060448.GA10203@elte.hu> <20080724063242.GA9051@elte.hu> <20080724073313.GA16604@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	David Newall <davidn@davidnewall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53471 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbYGXIgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 04:36:17 -0400
Content-Disposition: inline
In-Reply-To: <20080724073313.GA16604@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Willy Tarreau <w@1wt.eu> wrote:

> > 08:30:48.049354 IP (tos 0x0, ttl 64, id 27414, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> > 08:30:48.049359 IP (tos 0x0, ttl 64, id 27415, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> 
> And phoenix insists on getting what is missing from the window.
> 
> So dione is wrong here.

hm, but dione has been running the same 2.6.24.7-92.fc8 kernel for a 
long time:

/var/log/yum.log-20080528:May 27 23:44:36 Installed: kernel - 2.6.24.7-92.fc8.x86_64

and has 6 days uptime at the moment and no trouble communicating with 
any other buildbox - except the [only] one running latest -git.

	Ingo

From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 19:25:03 +0100
Message-ID: <20111229182502.GD2948@hell>
References: <1324664907.2915.5.camel@edumazet-laptop>
 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
 <1324668083.2915.15.camel@edumazet-laptop>
 <1325132760.2607.15.camel@edumazet-laptop>
 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
 <1325149922.2607.33.camel@edumazet-laptop>
 <20111229165249.GB2948@hell>
 <1325178950.2607.46.camel@edumazet-laptop>
 <20111229174323.GC2948@hell>
 <1325182236.2607.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39887 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751460Ab1L2SZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 13:25:05 -0500
Content-Disposition: inline
In-Reply-To: <1325182236.2607.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-12-29 19:10:36 [+0100]:

>I dont quite understand the question. The patch I posted is supposed to
>fix the problem. What do you want to tell to the user ?

I assumed that the patch makes it possible to replace standard tfifo?! Tfifo
provides strict ordering, other qdisc's do not. So I thought if someone use
netem rate|jitter with e.g. SFQ then this should be mentioned somewhere. E.g.
"rate|jitter can only be used with tfifo qdisc". Correct me if I am wrong.

Cheers

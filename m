From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 10:31:49 -0800
Message-ID: <20111229103149.7256369c@nehalam.linuxnetplumber.net>
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
	<20111229182502.GD2948@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52117 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab1L2Sbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 13:31:53 -0500
In-Reply-To: <20111229182502.GD2948@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Dec 2011 19:25:03 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * Eric Dumazet | 2011-12-29 19:10:36 [+0100]:
> 
> >I dont quite understand the question. The patch I posted is supposed to
> >fix the problem. What do you want to tell to the user ?
> 
> I assumed that the patch makes it possible to replace standard tfifo?! Tfifo
> provides strict ordering, other qdisc's do not. So I thought if someone use
> netem rate|jitter with e.g. SFQ then this should be mentioned somewhere. E.g.
> "rate|jitter can only be used with tfifo qdisc". Correct me if I am wrong.
> 
> Cheers

This is actually a feature. It is documented that tfifo can be replaced
with pfifo. In other words, if default (tfifo) is used then packets
can be reordered by the delay/jitter values. But if pfifo (or other
qdisc) is used, the packets will not be reordered.

From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sat, 15 Jun 2013 20:26:12 +0200
Message-ID: <1371320772.8319.2.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130613222411.GA5396@sig21.net>
	 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
	 <20130614055346.GB6547@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:55606 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3FOS0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 14:26:21 -0400
In-Reply-To: <20130614055346.GB6547@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 07:53 +0200, Johannes Stezenbach wrote:

> > Does it still pass traffic after that? Or is it actually dead?
> 
> It is dead.  Not interrupts, I tried ping from both ends
> of the link (link LED flashes on RX).

Can you check if one of RX actually works? It seems TX doesn't, at least
given the message, but it'd be good to know if RX actually worked? Just
trying ping obviously wouldn't determine that, maybe try tcpdump?

I don't see any difference between 8171 and 8161 in the TX code
though ...

johannes

From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Tue, 13 Apr 2010 09:56:25 +0200
Message-ID: <m3hbnfzsye.fsf@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	<q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
	<1271083479.2858.377.camel@ursa.amorsen.dk>
	<p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
	<1271091990.2858.409.camel@ursa.amorsen.dk>
	<u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>
	<1271138186.16881.168.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	zhigang gong <zhigang.gong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:50336 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112Ab0DMH4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 03:56:32 -0400
In-Reply-To: <1271138186.16881.168.camel@edumazet-laptop> (Eric Dumazet's
	message of "Tue, 13 Apr 2010 07:56:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Benny, I am not sure your irqbalance is up2date with multiqueue devices,
> you might need to disable it and manually irqaffine each interrupt

True, that would probably help. Irqbalance might just believe that the
load is so low that it isn't worth rebalancing. The CPU's are spending
more than 90% of their time idling.

I'll keep monitoring the server, and if it starts dropping packets again
or load increases I'll check whether irqbalanced does the right thing,
and if not I'll implement your suggestion.

Thank you very much!


/Benny

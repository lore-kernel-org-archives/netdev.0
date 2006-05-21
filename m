From: Andreas Kleen <ak@suse.de>
Subject: Re: [git patches] net driver updates
Date: Sun, 21 May 2006 15:24:24 +0200 (CEST)
Message-ID: <4579880.1148217864672.SLOX.WebMail.wwwrun@imap-dhs.suse.de>
References: <20060520042856.GA7218@havoc.gtf.org> <Pine.LNX.4.64.0605201035510.10823@g5.osdl.org> <20060520105547.220f2bea.akpm@osdl.org> <200605210015.15847.ak@suse.de> <447012B2.9050207@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:10476 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S964867AbWEUNY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 May 2006 09:24:27 -0400
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <447012B2.9050207@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> No idea, but unlikely. The fix removes a duplicate request_irq call.
> Is
> it possible that the both instances run concurrently?

The system has two Forcedeth ports, but only one has a cable connected.
I don't think there is any parallelism. Just one connection with a lot
of data. It didn't happen with 2.6.16.

If you don't have any other good ideas I will try to track it down.

-Andi


From: Andi Kleen <ak@suse.de>
Subject: Re: [git patches] net driver updates
Date: Mon, 22 May 2006 14:46:23 +0200
Message-ID: <200605221446.24135.ak@suse.de>
References: <20060520042856.GA7218@havoc.gtf.org> <4579880.1148217864672.SLOX.WebMail.wwwrun@imap-dhs.suse.de> <44707F8E.8010506@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:19856 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750802AbWEVMqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 08:46:30 -0400
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <44707F8E.8010506@colorfullife.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I don't have any good ideas, please try to figure out what's wrong. Is 
> there a debug switch for the network layer that forces the network layer 
> to verify the CHECKSUM_UNNECESSARY blocks?
> 

Good news. The latest -git driver seems to fix the problem.

So maybe something got broken with the double request_irq.

-Andi

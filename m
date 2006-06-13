From: David Miller <davem@davemloft.net>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Mon, 12 Jun 2006 21:49:48 -0700 (PDT)
Message-ID: <20060612.214948.124554804.davem@davemloft.net>
References: <200606121746.34880.ak@suse.de>
	<448DDBD9.6030900@goop.org>
	<200606130547.49624.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, lkml@rtr.ca, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63129
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932879AbWFMEtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 00:49:39 -0400
To: ak@suse.de
In-Reply-To: <200606130547.49624.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 13 Jun 2006 05:47:49 +0200

> I've been playing with the idea of writing "early1394" that just
> turns the DMA controller on as early as possible similar to earlyprintk
> on the target. Then it would be possible to use it for early
> debugging too. But so far it's not done yet.

Does this raw1394 thing with firescope just assume DMA address ==
physical address?  How would it work to access all of physical
memory properly on IOMMU platforms?

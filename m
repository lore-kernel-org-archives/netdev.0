From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 16:19:49 +0100
Message-ID: <1158592789.6069.115.camel@localhost.localdomain>
References: <p73k6414lnp.fsf@verdi.suse.de> <p73eju94htu.fsf@verdi.suse.de>
	 <20060918.070905.98863400.davem@davemloft.net>
	 <200609181629.53949.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, master@sectorb.msk.ru,
	hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:10910 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751717AbWIRO5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 10:57:00 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200609181629.53949.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Llu, 2006-09-18 am 16:29 +0200, ysgrifennodd Andi Kleen:
> The only delay this would add would be the queueing time from the NIC
> to the softirq. Do you really think that is that bad?

If you are trying to do things like network record/playback then you
want the minimal delay. There's a reason the original timestamp code
supported the hardware setting the timestamp itself - we actually had a
separare set of logic on a board that was doing the timestamping by
watching the IRQ line of the NIC chip.

Alan


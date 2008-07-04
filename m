From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 12:09:08 +0200
Message-ID: <87ej6armez.fsf@basil.nowhere.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	<20080703173040.GB30506@mit.edu>
	<1215111362.10393.651.camel@pmac.infradead.org>
	<20080703.162120.206258339.davem@davemloft.net>
	<486D6DDB.4010205@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tytso@mit.edu, jeff@garzik.org,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:15146 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbYGDKLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 06:11:05 -0400
In-Reply-To: <486D6DDB.4010205@infradead.org> (David Woodhouse's message of "Fri, 04 Jul 2008 01:24:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> writes:
>
> I'll look at making the requirement for 'make firmware_install' more
> obvious, or even making it happen automatically as part of
> 'modules_install'.

Perhaps I didn't pay enough attention, but how are "only 
boot bzImage without initrd or modules" setups supposed to work now
for those drivers? My testing setup relies on that heavily.

Will the firmware automatically end up in initramfs and be included
in the bzImage and loaded at the right point?

I hope we won't let lawyers decide technical topics here.

-Andi

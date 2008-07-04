From: David Miller <davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 13:43:29 -0700 (PDT)
Message-ID: <20080704.134329.209642254.davem@davemloft.net>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	<486E2818.1060003@garzik.org>
	<20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYGDUna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 16:43:30 -0400
In-Reply-To: <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 4 Jul 2008 14:27:53 +0100

> There are good sound reasons for having a firmware tree, the fact tg3 is
> a bit of dinosaur in this area doesn't make it wrong.

And bnx2, and bnx2x, and e100's ucode (hope David caught that one!).

It isn't just tg3.

External firmware is by design an error prone system, even with
versioning.  But by being built and linked into the driver, it
is fool proof.

On a technical basis alone, we would never disconnect a crucial
component such as firmware, from the driver.  The only thing
charging these transoformations, from day one, is legal concerns.

I've been against request_firmware() from the beginning, because
they make life unnecessarily difficult, and it is error prone no
matter how well you design the validation step.

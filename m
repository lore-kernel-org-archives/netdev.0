From: David Miller <davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 03 Jul 2008 13:34:28 -0700 (PDT)
Message-ID: <20080703.133428.22854563.davem@davemloft.net>
References: <486CC440.9030909@garzik.org>
	<Pine.LNX.4.64.0807031353030.11033@blonde.site>
	<486CCFED.7010308@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754884AbYGCUe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 16:34:28 -0400
In-Reply-To: <486CCFED.7010308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 03 Jul 2008 09:11:09 -0400

> dwmw2 has been told repeatedly that his changes will cause PRECISELY 
> these problems, but he refuses to take the simple steps necessary to 
> ensure people can continue to boot their kernels after his changes go in.
> 
> Presently his tg3 changes have been nak'd, in part, because of this 
> obviously, forseeable, work-around-able breakage.

I agree with Jeff, obviously.

We both saw this song and dance coming.  Now the reports are coming in
from confused people who are losing their network.  It is no surprise.

And the person who introduced this swath of regressions acts like it's
some kind of chore to enforce the obviously correct default behavior.

Why is it such a big deal to make "obviously working" the default?

In effect, you lied to us, in that you said that by default users
wouldn't have to do anything to keep getting a working setup.  But
that is provably not true, look at all of these reports.  Are you
saying these people are idiots and don't know how to configure their
kernel?  Every single one of them?

So don't be surprised how pissed off some of us are about these
changes.  You are inflicting pain on driver maintainers because now
they have to sift through these "firmware not found" reports in
addition to their normal workload.

And David make it seem like it's inconvenient for him to implement the
correct default, which in particular pisses me personally off the
most.  It's totally irresponsible, and I don't care what the legal or
ideological motivation is.

Given that, how in the world can you be surprised that the effected
driver maintainers have no interest in reviewing the substance of
these patches?  You don't piss people off, then say "help me review
this stuff."  It doesn't work like that.


From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: [RFT] skge: fiber carrier handling
Date: Thu, 12 Jul 2007 15:24:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0707121514180.9995@potato.cts.ucla.edu>
References: <20070710183953.GA8898@havoc.gtf.org> <Pine.LNX.4.64.0707111128330.31463@twin.jikos.cz>
 <Pine.LNX.4.64.0707110920270.11697@potato.cts.ucla.edu>
 <20070712145601.72417b42@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jiri Kosina <jikos@jikos.cz>, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-2.smtp.ucla.edu ([169.232.47.136]:59789 "EHLO
	smtp-2.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778AbXGLWZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 18:25:10 -0400
In-Reply-To: <20070712145601.72417b42@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007, Stephen Hemminger wrote:

> Does this fix your problems?  I don't have dual port boards but have an 
> old SK-9843 fiber board.

Nope.  It still hangs with:

fresno:~# ip li set eth2 up
fresno:~# ip li set eth2 down
fresno:~# ip li set eth3 up

This is with 2.6.22.1

If I load the sk98lin driver, I don't have any problems changing link 
state on both ports:

fresno:~# rmmod skge
fresno:~# modprobe sk98lin RlmtMode=DualNet
fresno:~# ip li set eth2 up
fresno:~# ip li set eth2 down
fresno:~# ip li set eth3 up
fresno:~# ip li set eth3 down



-Chris

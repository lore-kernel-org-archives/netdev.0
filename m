From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: ATM bug found
Date: Sun, 01 Oct 2006 11:22:56 -0400
Message-ID: <200610011522.k91FMumH006619@cmf.nrl.navy.mil>
References: <20061001145829.GA83074@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: Jeff Garzik <jeff@garzik.org>, Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:55185 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750974AbWJAPXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 11:23:13 -0400
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: <20061001145829.GA83074@gaz.sfgoth.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <20061001145829.GA83074@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>The fix is for alloc_shaper() should really do "*pcr = ATM_MAX_PCR" in
>the "if (ubr)" stanza.  Chas, want to submit that in the next batch
>of patches?

i dont think you can do that.  pcr gets assigned to .min_pcr and .min_pcr
= ATM_MAX_PCR has a different meaning.  it should probably be set to 0.
there is no minimum or maximum pcr for ubr.  you get what you get.

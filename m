From: Sebastian Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH / RFC] net: fix locking in ibm_newemac
Date: Thu, 14 Aug 2008 09:33:19 +0200
Message-ID: <20080814073319.GA8716@Chamillionaire.breakpoint.cc>
References: <20080813182957.GA12612@www.tglx.de> <1218685554.8041.172.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Sebastian Siewior <bigeasy@linutronix.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Valentine Barshak <vbarshak@ru.mvista.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50198 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751908AbYHNHd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 03:33:28 -0400
Content-Disposition: inline
In-Reply-To: <1218685554.8041.172.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Benjamin Herrenschmidt | 2008-08-14 13:45:54 [+1000]:

>> The fix is to defer phy init until netdevice is registered / initialized.
>
>I think it's better instead to take the dev_mc_add() statement
>out of emac_configure().
I looked yesterday into that code and I saw that dev_mc_add() was called
by the network core itself. Now I'm sure it was definitly too late for
writing patches :)

>What about this patch instead, does it fix it for you ?
yep it does.

Sebastian

From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] airo: make debug-like messages printed by	airo_print_dbg()
Date: Sun, 09 Jul 2006 21:55:41 +0400
Message-ID: <44B1431D.3010405@tls.msk.ru>
References: <44AFD651.8030801@net-pr.de> <1152455044.2519.7.camel@localhost.localdomain> <44B13974.9090604@net-pr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:18520 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1161026AbWGIRzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 13:55:46 -0400
To: Robert Schulze <rob@net-pr.de>
In-Reply-To: <44B13974.9090604@net-pr.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Schulze wrote:
> Hi,
> 
> Dan Williams schrieb:
>> This message will only happen if the card hangs up and stops responding
>> to commands anyway, so we don't necessarily care about making the
>> message decipherable to anyone other than developers.
> 
> Well, I get this message each time I insert my Cisco Aironet 350 PCMCIA
> card, which works obviously fine.
[]
> Besides, the messages can be read by issuing dmesg even after the patch,
> so no information gets lost.

The fact that you're getting that message indicates that something's wrong,
at least from the kernel's point of view.  So it better be understand and
fixed, instead of being hidden in debugging output.  If it's visible in
dmesg but isn't visible in syslog (default syslog configuration does not
capture any debugging messages), far less people will notice it.

I'd vote for making it one-line, but with current KERN_ERR priority.

/mjt (who don't even have the hardware in question)

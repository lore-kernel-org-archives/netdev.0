From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: ACPI Enable lan91x adapters
Date: Sun, 26 Jun 2016 11:15:21 +0200
Message-ID: <871t3k9uqe.fsf@belgarion.home>
References: <1466774181-24309-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, nico@fluxnic.net, davem@davemloft.net,
	fw@strlen.de, felipe.balbi@linux.intel.com, arnd@arndb.de,
	ahs3@redhat.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:34403 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbcFZJP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 05:15:28 -0400
In-Reply-To: <1466774181-24309-1-git-send-email-jeremy.linton@arm.com> (Jeremy
	Linton's message of "Fri, 24 Jun 2016 08:16:21 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Linton <jeremy.linton@arm.com> writes:

> Enable lan91x adapters in some ARM machines and models
> when booted with an ACPI kernel.
>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Hi Jeremy,

I launched your change in my Jenkins yesterday (on Linus's mainline, not
linux-next), and I got:

CC      drivers/net/ethernet/smsc/smc91x.o
drivers/net/ethernet/smsc/smc91x.c:2488:23: error: 'smsc91x_acpi_match' undeclared here (not in a function)
   .acpi_match_table = smsc91x_acpi_match,

This platform build is _not_ for an device tree platform,
ie. CONFIG_OF=n. You'll have to move some around it seems.


Cheers.

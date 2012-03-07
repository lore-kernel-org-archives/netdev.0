From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 4/7] [PATCH] ctcm: make ctcmpc debugging compilable
Date: Wed, 07 Mar 2012 17:53:12 +0100
Message-ID: <1331139192.15095.12.camel@br9gv9yg.de.ibm.com>
References: <OFA80676C5.CF55E2E0-ONC12579BA.005B3444-C12579BA.005B44A4@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Uschi IBM <ursula.braun@de.ibm.com>, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:38224 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756188Ab2CGQxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 11:53:17 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 7 Mar 2012 16:53:15 -0000
In-Reply-To: <OFA80676C5.CF55E2E0-ONC12579BA.005B3444-C12579BA.005B44A4@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "David Laight" <David.Laight@aculab.com>
> To: <frank.blaschka@de.ibm.com>, <davem@davemloft.net>
> Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
>  <ursula.braun@de.ibm.com> 
> Date: 07/03/2012 13:20
> Subject: RE: [patch 4/7] [PATCH] ctcm: make ctcmpc debugging compilable
> 
> What is wrong with:
>                  char addr[24];
>                  snprintf(addr, sizeof addr, "%p", rptr);
> 
> There seemed to be other 'dangerous' unbounded string
> operations in that code as well.
> 
>                  David

David,

nothing is wrong with your proposal to make use of %p here. Quite the
contrary - it improves the ctcmpc-code. I will keep your proposal in my
mind for a future follow-on ctcmpc-patch. Thanks!

My patch targets compilability of ctcmpc debugging code only.

Ursula

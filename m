From: Alan Cox <alan@redhat.com>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non pausing driver core
Date: Mon, 9 Jun 2008 20:13:29 -0400
Message-ID: <20080610001329.GA16197@devserv.devel.redhat.com>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	alan@redhat.com, randy.dunlap@oracle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238AbYFJAOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 20:14:22 -0400
Content-Disposition: inline
In-Reply-To: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be clearer on this

> +obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o 8390p.o

That line is wrong. Perhaps Andrew could post the original split patches
instead ?

> diff -puN drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core drivers/net/ne2.c
> --- a/drivers/net/ne2.c~8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core
> +++ a/drivers/net/ne2.c

And this has a single missed ei to eip conversion.



Alan


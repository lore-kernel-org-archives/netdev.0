From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch for 2.6.27? 4/6] drivers/net/mlx4/alloc.c needs mm.h
Date: Fri, 05 Sep 2008 16:44:43 -0700
Message-ID: <adafxoeqhsk.fsf@cisco.com>
References: <200809052104.m85L47vw020360@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:54887 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbYIEXop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 19:44:45 -0400
In-Reply-To: <200809052104.m85L47vw020360@imap1.linux-foundation.org>
	(akpm@linux-foundation.org's message of "Fri, 05 Sep 2008 14:04:07
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > drivers/net/mlx4/alloc.c:164: error: 'PAGE_KERNEL' undeclared (first use in this function)

 > +#include <linux/mm.h>

Looks like a good fix to me.

 - R.

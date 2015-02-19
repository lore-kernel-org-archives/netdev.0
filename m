From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] caif: fix a signedness bug in cfpkt_iterate()
Date: Thu, 19 Feb 2015 12:59:44 +0300
Message-ID: <20150219095944.GD25513@mwanda>
References: <20150219091313.GA29358@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE5EE1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39675 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbBSKAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 05:00:10 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE5EE1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 09:49:00AM +0000, David Laight wrote:
> From:  Dan Carpenter
> ...
> > Also this isn't ever going to be inlined so I removed the "inline".
> ...
> > -inline u16 cfpkt_iterate(struct cfpkt *pkt,
> > -			 u16 (*iter_func)(u16, void *, u16),
> > -			 u16 data)
> 
> static ??

There are some words missing in this sentence.


We could move this function to the header file and make it static inline
if we wanted but checksums aren't used on the fast path anyway so that's
a bit pointless.

regards,
dan carpenter

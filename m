From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 12:23:46 -0700
Message-ID: <adaskubdk8t.fsf@cisco.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:17804 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYGOTaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:30:25 -0400
In-Reply-To: <487B6569.5000806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:41 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +/*
 > + * Useful macros
 > + */
 > +
 > +#define ROUNDUP_LOG2(x)		ilog2(roundup_pow_of_two(x))

<linux/log2.h> calls this order_base_2()

 > +#define XNOR(x, y)		(!(x) == !(y))

You only use this once, and I think it would be much clearer to just
open-code this there -- I don't think "XNOR" is sufficiently
self-documenting.

 > +#define MIN(a, b)		((a) < (b) ? (a) : (b))
 > +#define MAX(a, b)		((a) > (b) ? (a) : (b))

Don't worry -- the min()/max() macros in <linux/kernel.h> won't wear out
from overuse.

 - R.

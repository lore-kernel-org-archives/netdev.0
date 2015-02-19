From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch] caif: fix a signedness bug in cfpkt_iterate()
Date: Thu, 19 Feb 2015 09:49:00 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE5EE1@AcuExch.aculab.com>
References: <20150219091313.GA29358@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:64940 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbbBSJth convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 04:49:37 -0500
In-Reply-To: <20150219091313.GA29358@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:  Dan Carpenter
...
> Also this isn't ever going to be inlined so I removed the "inline".
...
> -inline u16 cfpkt_iterate(struct cfpkt *pkt,
> -			 u16 (*iter_func)(u16, void *, u16),
> -			 u16 data)

static ??

> +int cfpkt_iterate(struct cfpkt *pkt,
> +		  u16 (*iter_func)(u16, void *, u16),
> +		  u16 data)

	David

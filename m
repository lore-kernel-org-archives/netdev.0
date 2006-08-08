From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 20:04:07 -0700 (PDT)
Message-ID: <20060807.200407.99201707.davem@davemloft.net>
References: <1155005186.5328.13.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46052
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751221AbWHHDEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:04:04 -0400
To: mchan@broadcom.com
In-Reply-To: <1155005186.5328.13.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 07 Aug 2006 19:46:26 -0700

> 4. Make tx_cons and tx_prod volatile to guarantee that
> tg3_start_xmit() and tg3_tx() will see the latest ring indices.

Marking variables volatile is always an error.

If the locks and memory barriers are in the right place,
you have nothing to worry about.  :-)


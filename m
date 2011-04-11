From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Add CAIF HSI Link Layer
Date: Sun, 10 Apr 2011 18:49:37 -0700 (PDT)
Message-ID: <20110410.184937.183052667.davem@davemloft.net>
References: <1302170262-3926-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linus.walleji@stericsson.com,
	daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752543Ab1DKBuN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 21:50:13 -0400
In-Reply-To: <1302170262-3926-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu,  7 Apr 2011 11:57:42 +0200

> +static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi=
)

I do not see what kind of locking prevents multiple threads of control
from entering this function at the same time, making your skb_peek()
sequences illegal.

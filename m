From: David Miller <davem@davemloft.net>
Subject: Re: [1/3] IRDA: Create new field tx_extra in skbuff
Date: Mon, 10 Nov 2008 12:51:16 -0800 (PST)
Message-ID: <20081110.125116.67111379.davem@davemloft.net>
References: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
To: avillaci@ceibo.fiec.espol.edu.ec
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752892AbYKJUvQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 15:51:16 -0500
In-Reply-To: <49185CBD.2040601@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alex Villac=ED=ADs Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date: Mon, 10 Nov 2008 11:09:33 -0500

> @@ -279,6 +279,14 @@
>  	 */
>  	char			cb[48];
> =20
> +	/*
> +	 * Additional space for layer-specific variables that need to
> +	 * survive past dev_queue_xmit(), which clobbers cb above.
> +	 * Intended for use by drivers that need additional layer-specific
> +	 * parameters in order to transmit a packet properly.
> +	 */
> +	char			tx_extra[32];
> +

This kind of bloat is absolutely not acceptable.

With IRDA as the only user of this thing, %99.99999 of systems out
there will just have this wasted space doing absolutely nothing.

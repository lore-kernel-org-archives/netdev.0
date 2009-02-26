From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar : Do right check on num_txbdfree
Date: Thu, 26 Feb 2009 02:03:18 -0800 (PST)
Message-ID: <20090226.020318.50178027.davem@davemloft.net>
References: <49A6595A.9000405@arvoo.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: rini@arvoo.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754912AbZBZKDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 05:03:51 -0500
In-Reply-To: <49A6595A.9000405@arvoo.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rini van Zetten <rini@arvoo.nl>
Date: Thu, 26 Feb 2009 09:56:58 +0100

> This patch fixes a wrong check on num_txbdfree. It could lead to
> num_txbdfree become nagative.  Result was that the gianfar stops
> sending data.
> 
> Signed-off-by: Rini van Zetten <rini at arvoo dot nl

Please use rini@arvoo.nl in your signoffs, you cannot
hide on the inna-net.

> -	if (nr_frags > priv->num_txbdfree) {
> +	if ( (nr_frags+1) > priv->num_txbdfree) {

Please don't put a space between the parens there "( (", like
that.

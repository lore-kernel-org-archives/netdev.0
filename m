From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC][PATCH] net: ipv4: ipconfig: decrease CONF_CARRIER_TIMEOUT
Date: Wed, 2 May 2012 16:59:16 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F03@saturn3.aculab.com>
References: <1335972259-20975-1-git-send-email-c.hemp@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Christian Hemp" <c.hemp@phytec.de>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40333 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750991Ab2EBP7c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 11:59:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18441-04 for <netdev@vger.kernel.org>;
 Wed,  2 May 2012 16:59:28 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1335972259-20975-1-git-send-email-c.hemp@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> A timeout of two minutes is pretty anoying if _no_ ethernet cable
> is attached by purpose.  This patch decreases the timeout of
> CONF_CARRIER_TIMEOUT to an accaptable value of 10 secounds.
> 
...
>  
>  /* Define the friendly delay before and after opening net devices */
>  #define CONF_POST_OPEN		10	/* After 
> opening: 10 msecs */
> -#define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
> +#define CONF_CARRIER_TIMEOUT	1000	/* Wait for carrier timeout */

Doesn't that reduce it to 1 second!

I'm also not all sure how long it might take.
I'm sure there are some switches/routers that can take quite a while
do negotiate the link.
Usually noticed when dhcp takes links down and up as it assigns
an address.

	David

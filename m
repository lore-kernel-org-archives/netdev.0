From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] wan: new driver retina
Date: Thu, 25 Oct 2007 05:18:36 -0400
Message-ID: <47205F6C.7000907@pobox.com>
References: <586461.49400.qm@web52009.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, info@dcombus.com, netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58575 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbXJYJSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 05:18:46 -0400
In-Reply-To: <586461.49400.qm@web52009.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Not sure what's going on, but your patch looks scrambled, as scripts 
look at it:

> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>=0A=0AAdding Retina G.7=
> 03 and G.SHDSL driver.=0A=0ASigned-off-by: Matti Linnanvuori <mattilinnanvu=
> ori@yahoo.com>=0A---=0A=0AFixing bugs and style according to netdev mailing=
>  list comments.=0A=0Adiff -Napur linux-2.6.23/drivers/net/wan/Kconfig linux=
> -2.6.24/drivers/net/wan/Kconfig=0A--- linux-2.6.23/drivers/net/wan/Kconfig=
> =092007-10-09 23:31:38.000000000 +0300=0A+++ linux-2.6.24/drivers/net/wan/K=
> config=092007-10-25 09:23:19.933170522 +0300=0A@@ -494,4 +494,15 @@ config =
> SBNI_MULTILINE=0A =0A =09  If unsure, say N.=0A =0A+config RETINA=0A+=09tri=
> state "Retina support"=0A+=09depends on PCI=0A+=09help=0A+=09  Driver for R=

Its been mangled into "Content-Transfer-Encoding: quoted-printable" by 
your mailer.

Also, when you revise a patch, please note somehow that this is an 
updated version.  One convention is changing the subject line:

	[PATCH v3] wan: new driver retina

Otherwise I have an mbox full of seemingly-similar patches, all with the 
subject "wan: new driver retina"

	Jeff



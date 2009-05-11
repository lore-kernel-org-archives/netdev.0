From: "chaithrika" <chaithrika@ti.com>
Subject: RE: [PATCH net-next-2.6] TI DaVinci EMAC driver
Date: Mon, 11 May 2009 09:52:00 +0530
Message-ID: <026301c9d1f0$07aa5750$16ff05f0$@com>
References: <1241789662-23721-1-git-send-email-chaithrika@ti.com> <20090509.131638.112506027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>, <nsekhar@ti.com>,
	<anantgole@ti.com>, <khilman@deeprootsystems.com>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:51736 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbZEKEW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 00:22:26 -0400
In-Reply-To: <20090509.131638.112506027.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, May 10, 2009 1:47 AM
> To: chaithrika@ti.com
> Cc: netdev@vger.kernel.org; davinci-linux-open-
> source@linux.davincidsp.com; nsekhar@ti.com; anantgole@ti.com;
> khilman@deeprootsystems.com
> Subject: Re: [PATCH net-next-2.6] TI DaVinci EMAC driver
> 
> From: Chaithrika U S <chaithrika@ti.com>
> Date: Fri,  8 May 2009 09:34:22 -0400
> 
> > diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> > index dcd5f15..34f1253 100644
> > --- a/drivers/net/Makefile
> > +++ b/drivers/net/Makefile
> > @@ -2,6 +2,9 @@
> >  # Makefile for the Linux network (ethercard) device drivers.
> >  #
> >
> > +davinci_emac_driver-objs := davinci_emac.o
> > +obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac_driver.o
> > +
> >  obj-$(CONFIG_E1000) += e1000/
> >  obj-$(CONFIG_E1000E) += e1000e/
> >  obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
> 
> If there is only one source file, this complicated construct
> is overkill.  Simply do something like:
> 
> obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o

OK. Will change the makefile entry.

Regards,
Chaithrika



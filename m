From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when
	CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Mon, 10 Mar 2008 14:17:28 +0100
Message-ID: <1205155048.4627.5.camel@p60365-ste>
References: <20070920220121.GF28784@loki.buserror.net>
	 <20080307163747.GF10545@ld0162-tx32.am.freescale.net>
	 <1205135421.3837.1.camel@p60365-ste>
	 <200803101205.16158.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:33686 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbYCJNRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2008 09:17:31 -0400
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id 8E252F49142
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 14:17:29 +0100 (CET)
In-Reply-To: <200803101205.16158.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 10.03.2008, 12:05 +0100 schrieb Laurent Pinchart:

> Your documentation patch states that
> 
> "The first reg resource is the I/O port register block on which MDIO
> resides.  The second reg resource is the I/O port register block on
> which MDC resides.  If there is only one reg resource, it is used for
> both MDIO and MDC."
> 
> If I'm not mistaken the code uses the first reg resource for MDC and the 
> second reg resource for MDIO. Which one should be fixed, the doc or the 
> code ?
> 
> Best regards,
> 
Ooops... Sorry...
You are right: the first is MDC, second MDIO.
I have to fix the docu, it would be simpler.

Thank you and best regards
Sergej.


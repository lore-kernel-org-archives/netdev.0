From: "Prodyut Hazarika" <phazarika@amcc.com>
Subject: RE: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt Coalescing
Date: Mon, 21 Sep 2009 17:05:31 -0700
Message-ID: <0CA0A16855646F4FA96D25A158E299D606FFE802@SDCEXCHANGE01.ad.amcc.com>
References: <1253573245-1867-1-git-send-email-phazarika@amcc.com> <1253576514.7103.165.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Feng Kan" <fkan@amcc.com>,
	"Loc Ho" <lho@amcc.com>, "Victor Gallardo" <vgallardo@amcc.com>,
	<bhutchings@solarflare.com>, <linuxppc-dev@lists.ozlabs.org>,
	<davem@davemloft.net>, <jwboyer@linux.vnet.ibm.com>,
	<lada.podivin@gmail.com>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sdcmail02.amcc.com ([198.137.200.90]:9051 "EHLO
	sdcmail02.amcc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543AbZIVAF1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 20:05:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1253576514.7103.165.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,
Thanks again for your comments.

> Same goes with the SDR register definitions. Prefix them with the SOC
> name but don't make them conditionally compiled.

I will add the base address in the Device tree, and make all register
definitions based on offset from the base in the next version of this
patch.

> Also, this coalescing option, while it makes sense to have a CONFIG
> option to compile in the support for it or not, the choice to use
> coalescing or not should be done at runtime. Same goes with the
various
> thresholds which should be runtime configurable.

Thanks for this comment. I will hookup ethtool with the EMAC driver, but
the MAL driver will come up with default coalesce options (as defined in
the appropriate defconfig file). The user will be able to change these
parameters as needed using ethtool.

I will get all the changes in place in the next version of this patch.

Thanks
Prodyut




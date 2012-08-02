From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 2 Aug 2012 10:25:38 -0400
Message-ID: <OFA8EDA0BC.A9D42E39-ON85257A4E.004ECE32-85257A4E.004F3FC7@us.ibm.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
	<CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>	<OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com> <CAOLNa-cMkHaFxoWym-oVT6i7ZZ25tZPxaAEcwUuT1TB4kPGfag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Dragos Ilie <dragos.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:48634 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab2HBOZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 10:25:52 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 2 Aug 2012 08:25:51 -0600
In-Reply-To: <CAOLNa-cMkHaFxoWym-oVT6i7ZZ25tZPxaAEcwUuT1TB4kPGfag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/02/2012 10:03:24 AM:

> > The QQIC would come from v2 queries prior to the v1 query that
> > triggered us to switch to v1. But, see below.
> 
> How about the scenario where you have only MLDv1 queriers? There will
> be no prior v2 query

        Yes, this is why I suggested initializing it to the
default of 125. If we actually saw v2 queries with different
intervals, we'd adjust longer or shorter, but use the default
only when we had no queries to update it.

                                                +-DLS

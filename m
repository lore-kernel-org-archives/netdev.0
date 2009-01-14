From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] Expanding ethtool PHY information
Date: Wed, 14 Jan 2009 18:01:46 +0100
Message-ID: <m3fxjles91.fsf@maximus.localdomain>
References: <1231879514.3005.31.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50309 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762919AbZANRBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 12:01:48 -0500
In-Reply-To: <1231879514.3005.31.camel@achroite> (Ben Hutchings's message of "Tue\, 13 Jan 2009 20\:45\:14 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> The set of port types reported through the ethtool API is looking a bit
> limited:
>
> /* Which connector port. */
> #define PORT_TP			0x00
> #define PORT_AUI		0x01
> #define PORT_MII		0x02
> #define PORT_FIBRE		0x03
> #define PORT_BNC		0x04

Perhaps using an ASCII string would be a better approach? Leaving the
old one for compatibility of course.
-- 
Krzysztof Halasa

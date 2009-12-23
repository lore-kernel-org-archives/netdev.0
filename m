From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Wed, 23 Dec 2009 13:48:26 -0800
Message-ID: <1261604906.609.106.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Loo <tloo@saltstorm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55600 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbZLWVtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:49:00 -0500
In-Reply-To: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

> This patch adds the Sony Ericsson J105i (Naite)
> mobile phone to the cdc_ether device whitelist,
> enabling access to the modem.
> 
> I would think more SE models of this generation
> (2009Q3) with builtin HSDPA modules also needs
> to be added to this list.

I do prefer if we NOT use the mbm_info details for this since they are
clearly for mobile broadband cards with FLAG_WWAN.

Since this is a phone where the setup of the connection is done via the
phone. And you just treat this as an Ethernet device and run DHCP, then
please create a se_info or similar with FLAG_ETHER.

Regards

Marcel



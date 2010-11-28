From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: adding support for Lancer family
 of CNAs
Date: Sat, 27 Nov 2010 22:52:01 -0800 (PST)
Message-ID: <20101127.225201.112605958.davem@davemloft.net>
References: <20101122092550.GA11076@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751413Ab0K1Gvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 01:51:35 -0500
In-Reply-To: <20101122092550.GA11076@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 22 Nov 2010 14:55:50 +0530

> Key changes are:
> - EQ ids are not assigned consecutively in Lancer. So, fix mapping of MSIx
>   vector to EQ-id.
> - BAR mapping and some req locations different for Lancer.
> - TCP,UDP,IP checksum fields must be compulsorily set in TX wrb for TSO in
>   Lancer.
> - CEV_IST reg not present in Lancer; so, peek into event queue to check for
>   new entries
> - cq_create and mcc_create cmd interface is different for Lancer; handle
>   accordingly
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thank you.

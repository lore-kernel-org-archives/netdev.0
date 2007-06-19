From: David Miller <davem@davemloft.net>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 15:28:01 -0700 (PDT)
Message-ID: <20070619.152801.99185860.davem@davemloft.net>
References: <20070619140038.GA13629@2ka.mipt.ru>
	<1182270529.4968.73.camel@localhost>
	<18040.5105.715624.286924@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, johnpol@2ka.mipt.ru, krkumar2@in.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com,
	sri@us.ibm.com
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753678AbXFSW1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 18:27:42 -0400
In-Reply-To: <18040.5105.715624.286924@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Tue, 19 Jun 2007 19:35:45 +0200

>  pktgen heavily uses gettimeofday. I was using tsc as clock source with 
>  our opterons in the lab. In late 2.6.20 gettimeofday was changed so tsc 
>  couldn't be used on opterons (pktgen at least). 
> 
>  To give you an example w.intel's 82571EB we could send 1.488 Mpps using tsc 
>  but with hpet only 400 kpps.

Converting pktgen over to ktime_t might be a nice cleanup.

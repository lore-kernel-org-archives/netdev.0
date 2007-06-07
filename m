From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 18:26:43 -0400
Message-ID: <1181255204.4071.31.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165215.38711917.davem@davemloft.net>
	 <20070607004712.GE3304@havoc.gtf.org> <1181219380.4064.55.camel@localhost>
	 <46681E41.6060700@intel.com> <1181253445.4071.4.camel@localhost>
	 <46688169.8080806@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.246]:19880 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935930AbXFGW0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:26:48 -0400
Received: by ag-out-0708.google.com with SMTP id 35so529872aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:26:47 -0700 (PDT)
In-Reply-To: <46688169.8080806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 15:06 -0700, Kok, Auke wrote:

> the contention isn't between multiple tx attempts, but between e1000_clean and 
> tx. 

I got you the first time but i think i am missing something:  given that
the lock is used only on tx - how is that protecting the contention
between tx and rx?

> You'll need bidirectional traffic with multiple clients probably to hit it...

I did - but it was asymettric i.e very heavy on tx.

cheers,
jamal


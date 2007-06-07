From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 18:57:54 -0400
Message-ID: <1181257074.4071.58.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165215.38711917.davem@davemloft.net>
	 <20070607004712.GE3304@havoc.gtf.org> <1181219380.4064.55.camel@localhost>
	 <46681E41.6060700@intel.com> <1181253445.4071.4.camel@localhost>
	 <46688169.8080806@intel.com> <1181255204.4071.31.camel@localhost>
	 <46688706.9040702@intel.com>
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
Received: from hu-out-0506.google.com ([72.14.214.230]:53910 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965380AbXFGW57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:57:59 -0400
Received: by hu-out-0506.google.com with SMTP id 19so411299hue
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:57:57 -0700 (PDT)
In-Reply-To: <46688706.9040702@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 15:30 -0700, Kok, Auke wrote:

> our rx interrupt/clean can trigger tx cleans, reaching the same code...

I see that - What i am saying is tx_lock never protects that.
Am i mistaken? i.e
CPU0 entering tx and and CPU1 entering rx interupt/clean can not be
blocked from each other simply by tp->tx_lock because tp->tx_lock only
runs on CPU0. 
Is it a bug then?

cheers,
jamal


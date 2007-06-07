From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 15:30:30 -0700
Message-ID: <46688706.9040702@intel.com>
References: <1181168020.4064.46.camel@localhost>	 <20070606.153530.48530367.davem@davemloft.net>	 <1181172766.4064.83.camel@localhost>	 <20070606.165215.38711917.davem@davemloft.net>	 <20070607004712.GE3304@havoc.gtf.org> <1181219380.4064.55.camel@localhost>	 <46681E41.6060700@intel.com> <1181253445.4071.4.camel@localhost>	 <46688169.8080806@intel.com> <1181255204.4071.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23838 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936505AbXFGWat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 18:30:49 -0400
In-Reply-To: <1181255204.4071.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-07-06 at 15:06 -0700, Kok, Auke wrote:
> 
>> the contention isn't between multiple tx attempts, but between e1000_clean and 
>> tx. 
> 
> I got you the first time but i think i am missing something:  given that
> the lock is used only on tx - how is that protecting the contention
> between tx and rx?

our rx interrupt/clean can trigger tx cleans, reaching the same code...

Auke

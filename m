From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 18:04:03 -0400
Message-ID: <1181253843.4071.8.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	 <20070606.154041.08321169.davem@davemloft.net>
	 <1181172946.4064.87.camel@localhost>
	 <20070606.165602.118948582.davem@davemloft.net>
	 <20070607090840.346f6a09@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.249]:9432 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965824AbXFGWEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:04:08 -0400
Received: by ag-out-0708.google.com with SMTP id 35so525407aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:04:08 -0700 (PDT)
In-Reply-To: <20070607090840.346f6a09@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 09:08 -0700, Stephen Hemminger wrote:

> 
> There could be bad packet reordering with this (like some SMP routers used to do).

You can avoid re-ordering if you guarantee that "related" flows always
end up on the same CPU via say tc filters i.e i dont think just a 5
tuple classification would be sufficient.

cheers,
jamal





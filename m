From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Wed, 30 Jan 2008 08:57:45 -0800
Message-ID: <47A0AC89.6080806@intel.com>
References: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com> <20080110.172830.16409182.davem@davemloft.net> <m3ir20ipoz.fsf@ursa.amorsen.dk> <20080111.174109.57502326.davem@davemloft.net> <20080112050841.M73900@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32769 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbYA3Q6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 11:58:33 -0500
In-Reply-To: <20080112050841.M73900@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Sorry. that i interfere in this subject.
> 
> Do you recommend CONFIG_IRQBALANCE to be enabled?

I certainly do not. Manual tweaking and pinning the irq's to the correct CPU will
give the best performance (for specific loads).

The userspace irqbalance daemon tries very hard to approximate this behaviour and
is what I recommend for most situations, it usually does the right thing and does
so without making your head spin (just start it).

The in-kernel one usually does the wrong thing for network loads.

Cheers,

Auke

From: Chris Snook <csnook@redhat.com>
Subject: Re: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
 quirk
Date: Mon, 17 Nov 2008 14:40:32 -0500
Message-ID: <4921C8B0.9060301@redhat.com>
References: <20081116.191252.80669091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38635 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbYKQTkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 14:40:37 -0500
In-Reply-To: <20081116.191252.80669091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I'm less than thrilled with this patch so I'm not going to apply it.
> 
> I mean, what are we going to do, for every single device that has a
> NVRAM we're going to add some PCI quirk and some new global foo_*
> kernel command line option to turn it off?
> 
> That doesn't make any sense at all, sorry.

Could we protect it in a PCI quirk, and optionally unprotect it in the 
driver?

-- Chris

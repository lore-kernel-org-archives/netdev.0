From: Andi Kleen <ak@suse.de>
Subject: Re: NetXen driver name
Date: 08 Feb 2007 19:15:09 +0100
Message-ID: <p734ppw349e.fsf@bingen.suse.de>
References: <200702082152.19772.amitkale@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Amit Kale <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48421 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965731AbXBHRO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 12:14:57 -0500
In-Reply-To: <200702082152.19772.amitkale@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit Kale <amitkale@netxen.com> writes:

> Hi,
> 
> NetXen ethernet driver present in 2.6.20 has name "netxen_nic". The product 
> itself is refered to as "nx_nic". To make it inline with the product, would 
> it be a good idea to change the name of the driver to "nx_nic"?

When it's already in a released kernel it's a little late to rename the module.
You would cause upgrade pain to users who have hardcoded the module name.

-Andi

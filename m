From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000: FIX: be ready for incoming irq at pci_request_irq
Date: Fri, 09 Mar 2007 12:38:41 -0500
Message-ID: <45F19BA1.3090408@garzik.org>
References: <20070306165721.27434.23796.stgit@localhost.localdomain> <45F18F7C.3030801@garzik.org> <45F1954D.4000506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58192 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbXCIRio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:38:44 -0500
In-Reply-To: <45F1954D.4000506@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Personally, I think this is really really needed. I'm surprised that you 
> already didn't push this considering Andrew pulled this into -mm 
> immediately.


Since it affects a fragile area of e1000 for all [e1000] users, I much 
prefer to err on the side of caution.  I have a history of pulling 
wide-impact fixes like this, late in -rc cycle, and having yet more 
breakage appear.

But if Andrew or Linus disagree, feel free to override me.  This is just 
area where I am intentionally over-cautious.

	Jeff





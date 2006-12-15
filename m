From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 14/14] e1000: No-delay link detection at interface up
Date: Fri, 15 Dec 2006 09:36:26 -0500
Message-ID: <4582B2EA.9010501@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175754.3365.137.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55221 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbWLOOg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:36:28 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175754.3365.137.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: No-delay link detection at interface up
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Currently after an interface up, the link state is detected 2 seconds later
> when the first watchdog timer runs. This patch changes that by triggering
> the hardware to generate a link-change interrupt from the up() function
> instead. This has the result that the link state gets detected immediately
> and without races. This has the potential to speed up booting since a normal
> distribution boot process waits for a link before DHCP is attempted.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

ACK, though you can also just schedule the timer to run immediately, or 
even run it yourself inside spin_lock_bh()

	Jeff




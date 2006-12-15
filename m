From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 05/14] e1000: Fix Wake-on-Lan with forced gigabit speed
Date: Fri, 15 Dec 2006 11:00:00 -0500
Message-ID: <4582C680.1050604@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175226.3365.119.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55822 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbWLOQAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 11:00:05 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175226.3365.119.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: Fix Wake-on-Lan with forced gigabit speed
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> If the user has forced gigabit speed, phy power management must be disabled;
> otherwise the NIC would try to negotiate to a linkspeed of 10/100 mbit on
> shutdown, which would lead to a total loss of link. This loss of link breaks
> Wake-on-Lan and IPMI.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

ACK patches 5 and 6



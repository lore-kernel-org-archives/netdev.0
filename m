From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 12/14] e1000: Make the copybreak value a module parameter
Date: Fri, 15 Dec 2006 09:35:13 -0500
Message-ID: <4582B2A1.2030700@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175639.3365.133.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55194 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbWLOOfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:35:15 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175639.3365.133.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: Make the copybreak value a module parameter
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Allow the user to vary the size that copybreak works. Currently cb is enabled
> for packets < 256 bytes, but various tests indicate that this should be
> configurable for specific use cases. In addition, this parameter allows us
> to force never/always during testing to get full and predictable coverage of 
> both code paths.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

ACK patches 11-12



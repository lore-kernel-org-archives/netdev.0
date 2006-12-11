From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 12/22] e1000: Fix powerdown link loss when forced to gig
 speed
Date: Mon, 11 Dec 2006 09:46:21 -0500
Message-ID: <457D6F3D.3040607@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230311.30109.32860.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46373 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760642AbWLKOqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:46:23 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230311.30109.32860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> disable phy power mode to prevent the NIC from attempting to autoneg
> to i10/100mbit when running in forced gig mode as it would lose link at
> shutdown. This allows you to force gig speed and still use WoL/IPMI
> after shutdow.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

ACK patches 9-12.  in case you're wondering why I didn't gripe about 
feature bits more:  Reset code [e1000_reset] will naturally have quite a 
few "if chip rev == blah" tests, and creating feature bits for each of 
those cases can be tedious.  However, flags should be used (a la tg3) 
rather than all these 'switch(rev)' statements and 'if (rev > x && rev < 
y)' statements.



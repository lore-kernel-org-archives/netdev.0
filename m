From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next v2] bonding: fix string comparison errors
Date: Tue, 26 Jul 2011 17:08:30 -0400
Message-ID: <20110726210829.GQ21309@gospo.rdu.redhat.com>
References: <1311714479-9260-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Vitalii Demianets <vitas@nppfactor.kiev.ua>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Takuma Umeya <tumeya@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421Ab1GZVIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 17:08:38 -0400
Content-Disposition: inline
In-Reply-To: <1311714479-9260-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2011 at 05:07:59PM -0400, Andy Gospodarek wrote:
> When a bond contains a device where one name is the subset of another
> (eth1 and eth10, for example), one cannot properly set the primary
> device or the currently active device.
> 
> This was reported and based on work by Takuma Umeya.  I also verified
> the problem and tested that this fix resolves it.
> 
> V2: A few did not like the the current code or my changes, so I
> re-factored bonding_store_primary and bonding_store_active_slave to be a
> bit cleaner, dropped the use of strnicmp since we did not really need
> the comparison to be case insensitive, and formatted the input string
> from sysfs so a comparison to IFNAMSIZ could be used.
> 
> I also discovered an error in bonding_store_active_slave that would
> modify bond->primary_slave rather than bond->curr_active_slave before
> forcing the bonding driver to choose a new active slave.
> 

Sorry I apparently cannot properly use git send-email. :-)


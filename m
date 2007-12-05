From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 7/11] ibm_newemac: Skip EMACs that are marked unused by
	the firmware
Date: Wed, 5 Dec 2007 15:21:26 +1100
Message-ID: <20071205042126.GE12855@localhost.localdomain>
References: <20071205001539.97730DE091@ozlabs.org> <20071205035345.GA12855@localhost.localdomain> <1196828329.13230.356.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51067 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbXLEEV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 23:21:29 -0500
Content-Disposition: inline
In-Reply-To: <1196828329.13230.356.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 03:18:49PM +1100, Benjamin Herrenschmidt wrote:
> 
> On Wed, 2007-12-05 at 14:53 +1100, David Gibson wrote:
> > It occurred to me the other day.  Instead of using a new "unused"
> > property for this, should we be using the OF standard "status"
> > property.
> 
> Dunno... it's really not wired. Probably not even clocked.

status = "fail-notconnected"; ?

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

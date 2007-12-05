From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 7/11] ibm_newemac: Skip EMACs that are marked unused by
	the firmware
Date: Wed, 5 Dec 2007 14:53:45 +1100
Message-ID: <20071205035345.GA12855@localhost.localdomain>
References: <20071205001539.97730DE091@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57339 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbXLEEHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 23:07:37 -0500
Content-Disposition: inline
In-Reply-To: <20071205001539.97730DE091@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 11:14:30AM +1100, Benjamin Herrenschmidt wrote:
> From: Hugh Blemings <hugh@blemings.org>
> 
> Depending on how the 44x processors are wired, some EMAC cells
> might not be useable (and not connected to a PHY). However, some
> device-trees may choose to still expose them (since their registers
> are present in the MMIO space) but with an "unused" property in
> them.

It occurred to me the other day.  Instead of using a new "unused"
property for this, should we be using the OF standard "status"
property.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

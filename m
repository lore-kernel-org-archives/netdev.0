From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 4/8] macb: initial support for Cadence GEM
Date: Fri, 11 Mar 2011 14:34:45 +0100
Message-ID: <20110311133445.GP9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-5-git-send-email-jamie@jamieiles.com>
 <20110311131415.GO9351@game.jcrosoft.org>
 <20110311133016.GF7357@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:51576 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752157Ab1CKNkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:40:16 -0500
Content-Disposition: inline
In-Reply-To: <20110311133016.GF7357@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13:30 Fri 11 Mar     , Jamie Iles wrote:
> On Fri, Mar 11, 2011 at 02:14:15PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> > > The Cadence GEM is based on the MACB Ethernet controller but has a few
> > > small changes with regards to register and bitfield placement.  This
> > > patch adds a new platform driver for gem which sets allows the driver to
> > > tell at runtime whether it is targetting a GEM device.
> > > 
> > > Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> > could we avoid all this if else everywhere?
> 
> I can't really see any other way to do this, but you're right it isn't 
> particularly nice.  Having said that, it is only in the initialization 
> code so there shouldn't be any real performance impact.
> 
> I'm open to ideas though!
use macro or inline at least

Best Regards,
J.

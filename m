From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 4/8] macb: initial support for Cadence GEM
Date: Fri, 11 Mar 2011 13:30:16 +0000
Message-ID: <20110311133016.GF7357@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-5-git-send-email-jamie@jamieiles.com>
 <20110311131415.GO9351@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33877 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab1CKNaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:30:22 -0500
Received: by bwz15 with SMTP id 15so2665880bwz.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 05:30:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110311131415.GO9351@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 02:14:15PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> > The Cadence GEM is based on the MACB Ethernet controller but has a few
> > small changes with regards to register and bitfield placement.  This
> > patch adds a new platform driver for gem which sets allows the driver to
> > tell at runtime whether it is targetting a GEM device.
> > 
> > Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> could we avoid all this if else everywhere?

I can't really see any other way to do this, but you're right it isn't 
particularly nice.  Having said that, it is only in the initialization 
code so there shouldn't be any real performance impact.

I'm open to ideas though!

Jamie

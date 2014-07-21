From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvebu: Can we make the orion-mdio clock a requirement?
Date: Mon, 21 Jul 2014 22:23:26 +0200
Message-ID: <20140721222326.668db913@free-electrons.com>
References: <20140721190614.GB20027@arch.cereza>
	<20140721212818.2d4920c4@free-electrons.com>
	<53CD743D.9080700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56472 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750821AbaGUUX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 16:23:29 -0400
In-Reply-To: <53CD743D.9080700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sebastian Hesselbarth,

On Mon, 21 Jul 2014 22:12:45 +0200, Sebastian Hesselbarth wrote:

> > However, yes, I tend to agree, making the clock mandatory would
> > probably be a good thing.
> 
> We can always pass TCLK on Orion5x if there is a need for a mandatory
> clock. Anyway, IIRC clock framework should now properly return
> -EPROPEDEFER only if there is a clock property set. If there is none,
> the error is different and can be catched on Orion5x.

Yes, I already use tclk on Orion5x for various clock references.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

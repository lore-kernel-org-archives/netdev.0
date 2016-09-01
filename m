From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: smsc911x: Fix register_netdev, phy startup,
 driver unload ordering
Date: Thu, 1 Sep 2016 21:22:43 +0200
Message-ID: <20160901192243.GA13292@lunn.ch>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-2-git-send-email-jeremy.linton@arm.com>
 <20160901165806.GC10951@lunn.ch>
 <a33771de-a591-d65e-90e8-33860100e40a@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757164AbcIAVXx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:53 -0400
Content-Disposition: inline
In-Reply-To: <a33771de-a591-d65e-90e8-33860100e40a@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch does add additional code I overlooked to cleanup the phy
> if it fails, I guess in theory that portion could be a prereq patch,
> I will break that portion out. I'm still not sure how to partially
> move the MDIO startup...

Hi Jeremy

You can add a cleanup patch which replaces these hard coded return
values with the value returned by the function calls. Then do the
move.

In general, it is easier to review lots of small obvious patches, than
one big patch with lots of things going on.

    Andrew

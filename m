From: David Miller <davem@davemloft.net>
Subject: Re: NIP6_FMT removal breaks
Date: Fri, 06 Feb 2009 03:13:37 -0800 (PST)
Message-ID: <20090206.031337.119386811.davem@davemloft.net>
References: <alpine.LSU.2.00.0902061131370.8140@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org, rjw@sisk.pl
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754457AbZBFLNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 06:13:40 -0500
In-Reply-To: <alpine.LSU.2.00.0902061131370.8140@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Fri, 6 Feb 2009 11:36:13 +0100 (CET)

> 
> Commit b189db5d299c6824780af5590564ff608adb3dea 
> (v2.6.28-rc2-82-gb189db5) broke external modules that make use of 
> NIP6_FMT. Since NIPQUAD_FMT has been left in place, I would consider the 
> removal of NIP6_FMT a regression. Objections?
> It is not critical though, as I can easily add an #if LINUX_VERSION_CODE
> >= xyz for the external modules.

NIPQUAD_FMT should die off too, there are only two users left
(both of which are iscsi).

The intention is to eliminate them all.

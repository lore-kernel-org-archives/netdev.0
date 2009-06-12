From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Thu, 11 Jun 2009 17:07:22 -0700 (PDT)
Message-ID: <20090611.170722.149033282.davem@davemloft.net>
References: <1244732090.2785.12.camel@achroite>
	<alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	<1244739166.2785.52.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, mfuzzey@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753695AbZFLAHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:07:20 -0400
In-Reply-To: <1244739166.2785.52.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 11 Jun 2009 17:52:46 +0100

> A clean solution would disable those modes altogether in the driver.

Absolutely agreed, in this specific case.  If that part of the
chip or the PHY is non-functional, it should be disabled in
the driver entirely.

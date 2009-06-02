From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: add phy_power_down parameter, leave phy
 powered up by default (v2)
Date: Tue, 02 Jun 2009 00:19:59 -0700 (PDT)
Message-ID: <20090602.001959.08867168.davem@davemloft.net>
References: <1243864477.13996.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com
To: eswierk@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757545AbZFBHT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:19:59 -0400
In-Reply-To: <1243864477.13996.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Swierk <eswierk@aristanetworks.com>
Date: Mon, 01 Jun 2009 06:54:37 -0700

> Add a phy_power_down parameter to forcedeth: set to 1 to power down the
> phy and disable the link when an interface goes down; set to 0 to always
> leave the phy powered up.
> 
> The phy power state persists across reboots; Windows, some BIOSes, and
> older versions of Linux don't bother to power up the phy again, forcing
> users to remove all power to get the interface working (see
> http://bugzilla.kernel.org/show_bug.cgi?id=13072).  Leaving the phy
> powered on is the safest default behavior.  Users accustomed to seeing
> the link state reflect the interface state and/or wanting to minimize
> power consumption can set phy_power_down=1 if compatibility with other
> OSes is not an issue.
> 
> Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

Applied, thanks Ed.

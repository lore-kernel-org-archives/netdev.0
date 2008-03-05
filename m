From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller
 (try #7)
Date: Wed, 05 Mar 2008 10:38:48 -0800 (PST)
Message-ID: <20080305.103848.218541004.davem@davemloft.net>
References: <20080303211743.GG2988@solarflare.com>
	<20080303.132941.176565936.davem@davemloft.net>
	<20080305142203.GQ2988@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dcbw@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752112AbYCESiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:38:52 -0500
In-Reply-To: <20080305142203.GQ2988@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 5 Mar 2008 14:22:04 +0000

> We propose to:
> 
> 1. Remove what we can - i.e. internal HW support, extraneous comments,
> unused HW register defines, and non-essential peripheral driver features
> such as sensor support - leaving a minimal network driver.
> 
> 2. Post the minimal driver in sub-100K patches to netdev.  This
> minimal driver will still require several patches, but future patches
> should represent independent pieces of functionality.

That sounds good.

You can even leave out the debugfs parts for now and add them
back in later, so that even that aspect can be reviewed seperately.

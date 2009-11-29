From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] sfc: Simplify PHY polling
Date: Sat, 28 Nov 2009 23:59:02 -0800 (PST)
Message-ID: <20091128.235902.02281632.davem@davemloft.net>
References: <1259422445.3709.2.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZK2H65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 02:58:57 -0500
In-Reply-To: <1259422445.3709.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:34:05 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Falcon can generate events for LASI interrupts from the PHY, but in
> practice we have never implemented this in reference designs.  Instead
> we have polled, inserted the appropriate events, and then handled the
> events later.  This is a waste of time and code.
> 
> Instead, make PHY poll functions update the link state synchronously
> and report whether it changed.  We can still make use of the LASI
> registers as a shortcut on the SFT9001.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

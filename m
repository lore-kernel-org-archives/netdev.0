From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] starfire: clean up properly if firmware loading
 fails
Date: Tue, 26 Jan 2010 20:49:16 -0800 (PST)
Message-ID: <20100126.204916.34896841.davem@davemloft.net>
References: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	michael@moffatt.org.nz, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658Ab0A0EtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 23:49:09 -0500
In-Reply-To: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 26 Jan 2010 20:27:09 -0800

> From: Ben Hutchings <bhutchings@solarflare.com>
> 
> netdev_open() will return without cleaning up net device or hardware state
> if firmware loading fails.  This results in a BUG() on a second attempt to
> bring the interface up, reported in
> <http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has even
> worse effects if the driver is removed afterwards.
> 
> Call netdev_close() to clean up on failure.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=15091
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Reported-by: Michael Moffatt <michael@moffatt.org.nz>
> Tested-by: Michael Moffatt <michael@moffatt.org.nz>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks everyone!

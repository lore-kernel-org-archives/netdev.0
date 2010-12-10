From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bridge: Fix return values of
 br_multicast_add_group/br_multicast_new_group
Date: Fri, 10 Dec 2010 13:01:25 -0800 (PST)
Message-ID: <20101210.130125.233714141.davem@davemloft.net>
References: <20101209082924.6d797871@nehalam>
	<1291903356-30618-1-git-send-email-tklauser@distanz.ch>
	<1291987084-27302-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753468Ab0LJVA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 16:00:57 -0500
In-Reply-To: <1291987084-27302-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 10 Dec 2010 14:18:04 +0100

> If br_multicast_new_group returns NULL, we would return 0 (no error) to
> the caller of br_multicast_add_group, which is not what we want. Instead
> br_multicast_new_group should return ERR_PTR(-ENOMEM) in this case.
> Also propagate the error number returned by br_mdb_rehash properly.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Looks good, applied to net-next-2.6

Please in the future make is clear, in your subject line, which
tree this patch is meant for.

I had to figure it out by trial and error, because this patch
does not apply properly to net-2.6


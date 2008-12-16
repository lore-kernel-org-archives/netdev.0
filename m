From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] tlan: fix earlier fixes, remove big buffer mode
Date: Tue, 16 Dec 2008 15:22:15 -0800 (PST)
Message-ID: <20081216.152215.48045394.davem@davemloft.net>
References: <4947C842.1020503@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakari.ailus@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753997AbYLPXWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:22:14 -0500
In-Reply-To: <4947C842.1020503@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sakari Ailus <sakari.ailus@iki.fi>
Date: Tue, 16 Dec 2008 17:24:50 +0200

> Unfortunately it seems that my last patch introduced a few problems.
> 
> So here are two patches: the first one fixes the pci memory
> unmapping. The second one removes the big buffer mode.

I think what I'm going to do is put your first patch into
net-2.6 and the bigbuf removal into net-next-2.6

Yes I realize that your changes might have made bigbuf even
more broken than it already is, that's fine since it's
off by default.

Thanks!

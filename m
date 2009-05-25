From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] Code changes to handle dev pvt
 ioctl
Date: Mon, 25 May 2009 00:34:22 -0700 (PDT)
Message-ID: <20090525.003422.117077559.davem@davemloft.net>
References: <20090524053149.GA17527@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758264AbZEYHeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:34:23 -0400
In-Reply-To: <20090524053149.GA17527@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Sun, 24 May 2009 11:01:58 +0530

> Resubmitting patch for net-next tree to handle SIOCDEVPRIVATE ioctl. Also
> have incorporated comments given by Ben Hutchings.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

So what kind of diagnostic commands do userlevel tools need
this for?

If they fall into useful generic categories, I'd rather you add new
ethtool commands for doing them, one for each diagnostic command.
For all I know, we might even have such things already if this is
for self-test, firmware upload/download, or similar.

Device private ioctls are heavily undesirable, because every driver
implements different ones, and thus the experience for users and tool
writers is completely inconsistent.

Until I know more about what this is going to be used for I am
rejecting this patch.

I really don't like any of the changes I've seen submitted recently
for the be2net driver, to be honest with you. :-/


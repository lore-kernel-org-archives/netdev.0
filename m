From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: fix off-by-one in ipip6_tunnel_get_prl
Date: Wed, 30 Sep 2009 16:40:07 -0700 (PDT)
Message-ID: <20090930.164007.256559861.davem@davemloft.net>
References: <1254259625-29320-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754777AbZI3Xjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:39:48 -0400
In-Reply-To: <1254259625-29320-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Tue, 29 Sep 2009 23:27:05 +0200

> When requesting all prl entries (kprl.addr == INADDR_ANY) and there are
> more prl entries than there is space passed from userspace, the existing
> code would always copy cmax+1 entries, which is more than can be handled.
> 
> This patch makes the kernel copy only exactly cmax entries.
> 
> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
> Acked-By: Fred L. Templin <Fred.L.Templin@boeing.com>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] af_ieee802154: fix ioctl processing
Date: Wed, 12 Aug 2009 20:51:59 -0700 (PDT)
Message-ID: <20090812.205159.79585617.davem@davemloft.net>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39282
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbZHMDvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:51:48 -0400
In-Reply-To: <1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Fri,  7 Aug 2009 16:58:37 +0400

> fix two errors in ioctl processing:
> 1) if the ioctl isn't supported one should return -ENOIOCTLCMD
> 2) don't call ndo_do_ioctl if the device doesn't provide it
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

This change is already in net-2.6, so submitting it for net-next-2.6
is superfluous.  It shows up when I merge net-2.6 into net-next-2.6,
which I keep doing periodically.

If you have dependencies with net-2.6 changes, simply tell me that
I need to merge net-2.6 into net-next-2.6 before applying your
net-next-2.6 patches


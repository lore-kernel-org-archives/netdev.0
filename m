From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] af_ieee802154: provide dummy get/setsockopt
Date: Wed, 05 Aug 2009 12:17:14 -0700 (PDT)
Message-ID: <20090805.121714.182898812.davem@davemloft.net>
References: <1249457297-8355-1-git-send-email-dbaryshkov@gmail.com>
	<1249457297-8355-2-git-send-email-dbaryshkov@gmail.com>
	<1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750797AbZHETRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:17:05 -0400
In-Reply-To: <1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Wed,  5 Aug 2009 11:28:16 +0400

> Provide dummt get/setsockopt implementations to stop these
> syscalls from oopsing on our sockets.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

See "sock_no_getsockopt()" and "sock_no_setsockopt()" which are
provided specifically for this situation.

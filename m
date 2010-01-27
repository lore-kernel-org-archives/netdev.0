From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix dst_release of invalid pointer
Date: Tue, 26 Jan 2010 23:11:33 -0800 (PST)
Message-ID: <20100126.231133.165423271.davem@davemloft.net>
References: <20100127070802.26065.73104.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754281Ab0A0HLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 02:11:22 -0500
In-Reply-To: <20100127070802.26065.73104.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 27 Jan 2010 12:38:02 +0530

> Fix dst_release on a invalid region.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

NULL, is NULL, is NULL, and always will be NULL.

Even if rt == NULL, &rt->u.dst will be NULL too.

So it's just plain NULL.

You NULL that? :-)


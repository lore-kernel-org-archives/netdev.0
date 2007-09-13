From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 v4] rfkill: Remove IRDA
Date: Thu, 13 Sep 2007 00:23:40 -0700 (PDT)
Message-ID: <20070913.002340.39179266.davem@davemloft.net>
References: <200709101954.50852.IvDoorn@gmail.com>
	<200709122014.26660.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dtor@insightbb.com, netdev@vger.kernel.org, inaky@linux.intel.com
To: ivdoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:40582
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750834AbXIMHXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 03:23:45 -0400
In-Reply-To: <200709122014.26660.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Wed, 12 Sep 2007 20:14:26 +0200

> As Dmitry pointed out earlier, rfkill-input.c
> doesn't support irda because there are no users
> and we shouldn't add unrequired KEY_ defines.
> 
> However, RFKILL_TYPE_IRDA was defined in the
> rfkill.h header file and would confuse people
> about whether it is implemented or not.
> 
> This patch removes IRDA support completely,
> so it can be added whenever a driver wants the
> feature.
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
> CC: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> CC: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied to net-2.6.24

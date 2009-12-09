From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri10ge: use src+dst for rss hashing
Date: Tue, 08 Dec 2009 20:25:14 -0800 (PST)
Message-ID: <20091208.202514.195686339.davem@davemloft.net>
References: <4B196A4F.5040408@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753529AbZLIEZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:25:07 -0500
In-Reply-To: <4B196A4F.5040408@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Fri, 04 Dec 2009 21:00:15 +0100

> Use a more effective rss hash by default (src + dst, rather than just src).
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied, but please get rid of this module parameter.

We have ethtool operations to configure this stuff, make
use of it instead of adding driver specific hacks.

Thank you.

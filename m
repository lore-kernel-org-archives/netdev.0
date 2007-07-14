From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Fri, 13 Jul 2007 23:19:26 -0700 (PDT)
Message-ID: <20070713.231926.74749058.davem@davemloft.net>
References: <46969CA9.8030406@hp.com>
	<Pine.LNX.4.64.0707130726550.30150@kivilampi-30.cs.helsinki.fi>
	<4697AE6E.4070600@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, shemminger@linux-foundation.org,
	noboru.obata.ar@hitachi.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbXGNGT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 02:19:26 -0400
In-Reply-To: <4697AE6E.4070600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 13 Jul 2007 09:55:10 -0700

> Fine, but so?  I suspect the point of the patch is to provide a
> lower cap on the accumulated backoff so data starts flowing over the
> connection within that lower cap once the link is
> restored/failed-over.

The backoff is there for a reason.

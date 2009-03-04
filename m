From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: more timeouts that reach -1
Date: Wed, 04 Mar 2009 00:05:26 -0800 (PST)
Message-ID: <20090304.000526.114653220.davem@davemloft.net>
References: <49A5286D.80304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752853AbZCDIFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 03:05:41 -0500
In-Reply-To: <49A5286D.80304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 25 Feb 2009 12:15:57 +0100

> These were not previously reported by me.
> ------------------------------>8-------------8<---------------------------------
> with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
> below are off by one.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks.

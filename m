From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix return ring size breakage
Date: Fri, 11 Sep 2009 16:57:36 -0700 (PDT)
Message-ID: <20090911.165736.208361181.davem@davemloft.net>
References: <1252711336.12629@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757172AbZIKX5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 19:57:20 -0400
In-Reply-To: <1252711336.12629@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mcarlson <mcarlson@broadcom.com>
Date: Fri, 11 Sep 2009 16:23:19 -0700

> Commit f6eb9b1fc1411d22c073f5264e5630a541d0f7df, "tg3: Add 5717 asic
> rev" changed how the rx return ring size operations are done.  It
> effectively inverts the sense of the previous test, but it failed to
> also invert the resulting sizes.  This patch corrects that error.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Confirmed to fix things here, applied, thanks!

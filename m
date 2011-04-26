From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Tue, 26 Apr 2011 12:49:37 -0700 (PDT)
Message-ID: <20110426.124937.39191750.davem@davemloft.net>
References: <1303776574.24299.3.camel@Joe-Laptop>
	<20110426013512.GA2031@mcarlson.broadcom.com>
	<1303841530.24299.37.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756471Ab1DZTuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:50:10 -0400
In-Reply-To: <1303841530.24299.37.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 26 Apr 2011 11:12:10 -0700

> Using a bitmap instead of separate u32 flags allows a consistent, simpler
> and more extensible mechanism to determine capabilities.
> 
> Convert bitmasks to enum.
> Add tg3_flag, tg3_flag_clear and tg3_flag_set.
> Convert the flag & bitmask tests.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I like this, Broadcom folks please review.

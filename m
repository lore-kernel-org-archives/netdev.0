From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: handle snprintf() return
Date: Mon, 26 Jul 2010 21:05:15 -0700 (PDT)
Message-ID: <20100726.210515.27818376.davem@davemloft.net>
References: <20100726072358.GK26313@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750751Ab0G0EE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 00:04:58 -0400
In-Reply-To: <20100726072358.GK26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 26 Jul 2010 09:23:59 +0200

> snprintf() returns the number of bytes that would have been written.  It
> can be larger than the size of the buffer.  The current code won't
> overflow, but people cut and paste this stuff so lets do it right and
> also make the static checkers happy.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.

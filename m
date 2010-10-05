From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cls_u32: signedness bug
Date: Tue, 05 Oct 2010 00:40:01 -0700 (PDT)
Message-ID: <20101005.004001.214209669.davem@davemloft.net>
References: <20101004122836.GB5692@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@vyatta.com, elendil@planet.nl,
	xiaosuo@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756137Ab0JEHjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:39:40 -0400
In-Reply-To: <20101004122836.GB5692@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 4 Oct 2010 14:28:36 +0200

> skb_headroom() is unsigned so "skb_headroom(skb) + toff" is also
> unsigned and can't be less than zero.  This test was added in 66d50d25:
> "u32: negative offset fix"  It was supposed to fix a regression.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> Compile tested only.  Please check.

This looks correct to me, thanks for fixing this.

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next]isdn: Kill directly reference of netdev->priv
Date: Wed, 03 Dec 2008 15:50:28 -0800 (PST)
Message-ID: <20081203.155028.56250603.davem@davemloft.net>
References: <4933F47F.5080809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751449AbYLCXu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:50:28 -0500
In-Reply-To: <4933F47F.5080809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 01 Dec 2008 22:28:15 +0800

> Simply use netdev_priv() to replace netdev->priv.
> 
> When I was making this patch, I fixed some checkpatch warning.
> But there are still some "line over 80 characters" warnings
> not fixed.
> Because if I fix such warning will change the code structure.
> 
> Dave if you don't like the checkpatch warning, please tell me.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks Wang.

This code is probably so full of such checkpatch issues that I don't
expect you to be required to fix them up just to make this change.

So don't worry :)

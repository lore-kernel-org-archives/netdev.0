From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] um: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 15:08:50 -0800 (PST)
Message-ID: <20081204.150850.118177410.davem@davemloft.net>
References: <4937D380.80104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758565AbYLDXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:08:50 -0500
In-Reply-To: <4937D380.80104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 04 Dec 2008 20:56:32 +0800

> Simply replace netdev->priv with netdev_priv().
> 
> Not do compile test, because no such arch.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

But, you don't need a special cpu or machine type to
compile these, "um" is "user-mode" Linux.  You should
be able to build that on plain x86 just fine.


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] CONNECTOR: add a proc entry to list connectors
Date: Fri, 27 Jun 2008 20:03:40 -0700 (PDT)
Message-ID: <20080627.200340.128759990.davem@davemloft.net>
References: <4860B279.9070105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizf@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45941
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752177AbYF1DDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:03:40 -0400
In-Reply-To: <4860B279.9070105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 24 Jun 2008 16:38:17 +0800

> I got a problem when I wanted to check if the kernel supports process
> event connector, and It seems there's no way to do this check.
> 
> At best I can check if the kernel supports connector or not, by looking
> into /proc/net/netlink, or maybe checking the return value of bind() to
> see if it's ENOENT.
> 
> So it would be useful to add /proc/net/connector to list all supported
> connectors:
>  # cat /proc/net/connector
>  Name            ID
>  connector       4294967295:4294967295
>  cn_proc         1:1
>  w1              3:1
> 
> Changelog:
> - fix memory leak: s/seq_release/single_release
> - use spin_lock_bh instead of spin_lock_irqsave
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> Acked-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: v2 [PATCH net-next 1/8] af_packet: Check return of
 dev_set_promiscuity/allmulti
Date: Tue, 01 Jul 2008 19:56:09 -0700 (PDT)
Message-ID: <20080701.195609.05458287.davem@davemloft.net>
References: <4869A251.108@cn.fujitsu.com>
	<4869A2D5.1010605@cn.fujitsu.com>
	<4869A502.90506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759833AbYGBC4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 22:56:08 -0400
In-Reply-To: <4869A502.90506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 01 Jul 2008 11:31:14 +0800

> Wang Chen said the following on 2008-7-1 11:21:
> > dev_set_promiscuity/allmulti might overflow.
> > Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> > dev_set_promiscuity/allmulti return error number if overflow happened.
> > 
> > In af_packet, we check all positive increment for promiscuity and allmulti
> > to get error return.
> > 
> 
> oops, the subject should be 1/7.
> sorry :(

I understood this :)

Please make the fixes requested by Patrick and resubmit.
The patches look otherwise fine to me.

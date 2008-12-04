From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 1/2]e1000: e1000_adapter->polling_netdev is useless
Date: Wed, 03 Dec 2008 22:07:39 -0800 (PST)
Message-ID: <20081203.220739.254257242.davem@davemloft.net>
References: <49353915.4060002@cn.fujitsu.com>
	<20081202.150623.70107608.davem@davemloft.net>
	<49368245.5040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752953AbYLDGHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:07:39 -0500
In-Reply-To: <49368245.5040804@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 03 Dec 2008 20:57:41 +0800

> David Miller said the following on 2008-12-3 7:06:
> > From: Wang Chen <wangchen@cn.fujitsu.com>
> > Date: Tue, 02 Dec 2008 21:33:09 +0800
> > 
> >> e1000_adapter->polling_netdev is not actually used after allocated.
> >> So, my question is that is it useless?
> > 
> > It's probably a leftover from before we added support for
> > multiqueue NAPI.
> > 
> > Intel folks can probably confirm.
> 
> Commit bea3348eef27e6044b6161fd04c3152215f96411
> "[NET]: Make NAPI polling independent of struct net_device objects."
> made NAPI polling to be independent of net_device.
> So e1000_adapter->polling_netdev is no longer used.
> Kill it.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks Wang.

Jeff, I know you said you are regression-testing this.  If you
find some problem we can revert or add a fix.

Thanks!

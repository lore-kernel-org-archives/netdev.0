From: David Miller <davem@davemloft.net>
Subject: Re: [Question] e1000: e1000_adapter->polling_netdev is useless
Date: Tue, 02 Dec 2008 15:06:23 -0800 (PST)
Message-ID: <20081202.150623.70107608.davem@davemloft.net>
References: <49353915.4060002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753775AbYLBXGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 18:06:23 -0500
In-Reply-To: <49353915.4060002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 02 Dec 2008 21:33:09 +0800

> e1000_adapter->polling_netdev is not actually used after allocated.
> So, my question is that is it useless?

It's probably a leftover from before we added support for
multiqueue NAPI.

Intel folks can probably confirm.

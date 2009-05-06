From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: update skb_recycle_check() for hardware
 timestamping changes
Date: Wed, 06 May 2009 16:49:26 -0700 (PDT)
Message-ID: <20090506.164926.232900375.davem@davemloft.net>
References: <20090506111311.GD24429@mail.wantstofly.org>
	<1241615499.26936.25.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752249AbZEFXtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:49:31 -0400
In-Reply-To: <1241615499.26936.25.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 06 May 2009 15:11:39 +0200

> On Wed, 2009-05-06 at 14:13 +0300, Lennert Buytenhek wrote:
>> Commit ac45f602ee3d1b6f326f68bc0c2591ceebf05ba4 ("net: infrastructure
>> for hardware time stamping") added two skb initialization actions to
>> __alloc_skb(), which need to be added to skb_recycle_check() as well.
> 
> Good catch, thanks. For what it's worth:
> 
> Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>

Applied, thanks everyone!

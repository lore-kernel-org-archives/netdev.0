From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Fri, 1 Aug 2014 03:33:26 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1408010331120.458@ws.cisco>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com> <1406634039-15030-3-git-send-email-_govind@gmx.com> <20140730.175306.483788306179792581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, ben@decadent.org.uk, netdev@vger.kernel.org,
	ssujith@cisco.com, benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:63043 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656AbaGaWDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 18:03:46 -0400
In-Reply-To: <20140730.175306.483788306179792581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2014, David Miller wrote:
> However I wonder what value that "max" thing has, I think setting the
> value to infinity is just fine, it just means every packet will be
> copied.
>
> So if we remove the 'max', we just have the copybreak itself, and you
> can therefore use ethtool_value and allocate the ethtool command
> numbers.

Yes, we can drop the max thing.

I will use ethtool_value and allocate new ethtool command for rx_copybreak
and send the patch soon.

Thanks

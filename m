From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Sat, 26 Jul 2014 16:19:16 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407261603450.3407@ws.cisco>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>   <1406050268-13329-3-git-send-email-_govind@gmx.com>  <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>  <alpine.LNX.2.03.1407230004150.15542@ws.cisco> <1406055025.7427.7.camel@deadeye.wl.decadent.org.uk>
 <alpine.LNX.2.03.1407230039010.15542@ws.cisco>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:51073 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbaGZKto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 06:49:44 -0400
In-Reply-To: <alpine.LNX.2.03.1407230039010.15542@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jul 2014, Govindarajulu Varadarajan wrote:

> On Tue, 22 Jul 2014, Ben Hutchings wrote:
>> No, you can't do that either.  Basically you can't change the size or
>> layout of any of the ethtool structures.
>
> Ok. Can you suggest me how I should add rx_copybreak to ethtool?
>
> May be add another function, set/get_rxcopybreak(), to ethtool_ops?
>
> Thanks
>

Should I drop the idea of ethtool and resubmit just the rx_copybreak changes?
(use module parameter to change rx_copybreak value).

Or should I try something like this
3de0b592394d17b 'ethtool: Support for configurable RSS hash key', Create new
ethtool cmd for changing driver rx_copybreak value.

Thanks

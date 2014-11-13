From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: fix work done in tx napi_poll
Date: Wed, 12 Nov 2014 22:18:50 -0500 (EST)
Message-ID: <20141112.221850.1446405025012689557.davem@davemloft.net>
References: <1415832126-31901-1-git-send-email-_govind@gmx.com>
	<5463F0C6.80501@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	edumazet@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbaKMDSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 22:18:53 -0500
In-Reply-To: <5463F0C6.80501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 12 Nov 2014 15:44:06 -0800

> On 11/12/2014 02:42 PM, Govindarajulu Varadarajan wrote:
>> With the commit d75b1ade567 ("net: less interrupt masking in NAPI") napi repoll
>> is done only when work_done == budget. In tx napi poll we always return 0.
>> So tx napi is not called again and we do not clean up the tx ring.
> 
> Good catch, I had exactly the same bug in bcmsysport.c, sounds like
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c could also need a fix.
> 
> Thanks!
> 
>> 
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks everyone.

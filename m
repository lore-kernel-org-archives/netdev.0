From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 7/8] macvlan: Check return of dev_set_allmulti
Date: Tue, 24 Jun 2008 13:38:52 +0200
Message-ID: <4860DCCC.1040806@trash.net>
References: <485B0011.7060601@cn.fujitsu.com> <485B7C32.8080605@trash.net> <485BC7E6.20308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48676 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbYFXLi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 07:38:59 -0400
In-Reply-To: <485BC7E6.20308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-6-20 17:45:
>> Please change this to use gotos for rollback on error.
>>
> 
> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Acked-by: Patrick McHardy <kaber@trash.net>

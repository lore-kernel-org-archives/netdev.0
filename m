From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 8/8] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Tue, 24 Jun 2008 13:41:29 +0200
Message-ID: <4860DD69.9070908@trash.net>
References: <485B001F.1070407@cn.fujitsu.com> <485B7C98.80302@trash.net> <485B801A.6090703@cn.fujitsu.com> <485B81B7.2020000@trash.net> <485BC7FC.1090005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48765 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbYFXLle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 07:41:34 -0400
In-Reply-To: <485BC7FC.1090005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check all positive increment for promiscuity and allmulti
> to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Acked-by: Patrick McHardy <kaber@trash.net>

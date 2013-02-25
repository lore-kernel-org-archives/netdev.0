From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: remove the unnecessary list_del
Date: Mon, 25 Feb 2013 13:03:04 +0800
Message-ID: <512AF088.5040206@cn.fujitsu.com>
References: <1361767316-28583-1-git-send-email-gaofeng@cn.fujitsu.com> <20130224.235411.1871885689914104471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:42052 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751507Ab3BYFEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2013 00:04:40 -0500
In-Reply-To: <20130224.235411.1871885689914104471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/02/25 12:54, David Miller wrote:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Mon, 25 Feb 2013 12:41:56 +0800
> 
>> These lists are used by unregister_netdevice_many,
>> they are local variables,will not be seen by others.
>> there is no need to delete them.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> What about the devices on the list?  The ones at the front and the
> rear of the list will have list pointers that point into no longer
> valid stack frame locations.

These lists are only used by unregister_netdevice_many,
we don't access these lists again after unregister_netdevice_many,
so I think it doesn't have invalid stack frame locations problems.

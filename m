From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Fri, 01 Aug 2008 18:16:32 +0800
Message-ID: <4892E280.8050907@cn.fujitsu.com>
References: <4892DC57.2060101@cn.fujitsu.com> <20080801.030834.245436720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55984 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbYHAKSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:18:38 -0400
In-Reply-To: <20080801.030834.245436720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-8-1 18:08:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 01 Aug 2008 17:50:15 +0800
> 
>> That make me think, what the use of netdev->priv?
>> We have netdev_priv() and use it flexibly. Why don't kill netdev->priv?
> 
> Way too many old drivers still reference netdev->priv directly.
> 
> Once we convert all of them to netdev_priv(), yes we can kill
> netdev->priv
> 

Thanks for the explanation.

Then next question comes.
We *have to* convert the drivers to use netdev_priv(), right?
Because, netdev->priv == netdev_priv() maybe change again in future,
just as before.


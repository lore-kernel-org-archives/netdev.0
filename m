From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/2] wan/pc300_drv: convert to net_device_ops
Date: Fri, 17 Apr 2009 01:15:22 -0700 (PDT)
Message-ID: <20090417.011522.90172631.davem@davemloft.net>
References: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
	<20090417014817.GA30721@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757394AbZDQIPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:15:30 -0400
In-Reply-To: <20090417014817.GA30721@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Fri, 17 Apr 2009 05:48:17 +0400

> On Fri, Apr 17, 2009 at 05:23:02AM +0400, Alexander Beregalov wrote:
>> +static const struct net_device_ops cpc_netdev_ops = {
>> +	.ndo_init		= NULL,
>> +	.ndo_open		= cpc_open,
>> +	.ndo_stop		= cpc_close,
>> +	.ndo_tx_timeout		= cpc_tx_timeout,
>> +	.ndo_set_multicast_list	= NULL,
> 
> In this case ndo_init and ndo_set_multicast_list
> are not needed.
 ...
> wan/pc300_drv: convert to net_device_ops
> 
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.

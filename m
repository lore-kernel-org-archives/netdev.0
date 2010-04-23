From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] sky2: add support for receive hashing
Date: Thu, 22 Apr 2010 21:32:26 -0400
Message-ID: <4BD0F8AA.2060700@garzik.org>
References: <20100422234255.150547953@vyatta.com> <20100422234319.149785036@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42771 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab0DWBcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 21:32:36 -0400
Received: by gyg13 with SMTP id 13so4838408gyg.19
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 18:32:35 -0700 (PDT)
In-Reply-To: <20100422234319.149785036@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2010 07:42 PM, Stephen Hemminger wrote:
> +static int sky2_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct sky2_port *sky2 = netdev_priv(dev);
> +
> +	if (data&  ETH_FLAG_LRO)
> +		return -EOPNOTSUPP;
> +
> +	if (data&  ETH_FLAG_NTUPLE)
> +		return -EOPNOTSUPP;


Minor nit:  you don't need separate tests for each bit.

	Jeff



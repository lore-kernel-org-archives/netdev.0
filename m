From: Gal Pressman <galp.dev@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Thu, 22 Jun 2017 11:17:13 +0300
Message-ID: <6c8de38c-5df4-279e-f653-4efd822f6dad@gmail.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-4-git-send-email-galp@mellanox.com>
 <20170621140318.GD27585@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Andrew Lunn <andrew@lunn.ch>, Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34588 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFVIRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 04:17:16 -0400
Received: by mail-wr0-f196.google.com with SMTP id k67so2687380wrc.1
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 01:17:16 -0700 (PDT)
In-Reply-To: <20170621140318.GD27585@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> +	if (!netif_running(netdev)) {
>> +		ldr->reason = ETHTOOL_LINK_NETDEV_CARRIER_DOWN;
>> +		return 0;
>> +	}
> This is generic, will work for any interface. The same is true for
> ADMIN_DOWN. Either it is not required at all, since the information is
> available via other means, or it should be in the core.

I agree, will move it to the core.

>
> 	  Andrew

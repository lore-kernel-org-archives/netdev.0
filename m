From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 05:06:30 -0500
Message-ID: <1258365990.3251.33.camel@bigi>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:53962 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbZKPKOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:14:09 -0500
Received: by qyk4 with SMTP id 4so2513139qyk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 02:14:15 -0800 (PST)
In-Reply-To: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 17:53 +0800, Changli Gao wrote:

Just one small comment; sorry, i missed this the first time:

> +		if (dev == NULL)
>  			return -EINVAL;
>  		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
>  				     &mirred_idx_gen, &mirred_hash_info);
>  		if (IS_ERR(pc))
> -		    return PTR_ERR(pc);
> +			return PTR_ERR(pc);

One indent too many? 

cheers,
jamal


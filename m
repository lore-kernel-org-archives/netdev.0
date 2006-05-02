From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 001/100] TCP congestion module: add TCP-LP supporting
 for 2.6.16
Date: Tue, 2 May 2006 10:23:52 -0700
Message-ID: <20060502102352.7bf304fd@localhost.localdomain>
References: <3feffd230605010305o6e3b1511of1f75b17f2797e66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9174 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964940AbWEBRX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 13:23:59 -0400
To: "Wong Edison" <hswong3i@gmail.com>
In-Reply-To: <3feffd230605010305o6e3b1511of1f75b17f2797e66@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +/**
> + * struct lp
> + * @flag: TCP-LP state flag
> + * @sowd: smoothed OWD << 3
> + * @owd_min: min OWD
> + * @owd_max: max OWD
> + * @owd_max_rsv: resrved max owd
> + * @RHZ: estimated remote HZ
> + * @remote_ref_time: remote reference time
> + * @local_ref_time: local reference time
> + * @last_drop: time for last active drop
> + * @inference: current inference
> + *
> + * TCP-LP's private struct.
> + * We get the idea from original TCP-LP implementation where only left those we
> + * found are really useful.
> + */
> +struct lp {
> +	u32 flag;
> +	u32 sowd;
> +	u32 owd_min;
> +	u32 owd_max;
> +	u32 owd_max_rsv;
> +	u32 RHZ;
> +	u32 remote_ref_time;
> +	u32 local_ref_time;
> +	u32 last_drop;
> +	u32 inference;
> +};

It is best to keep structure element names lower case.
s/RHZ/rhz/

or use remote_hz


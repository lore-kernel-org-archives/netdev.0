From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN
 exchange with SYNACK data
Date: Mon, 02 Nov 2009 10:16:38 -0800
Message-ID: <1257185798.28925.33.camel@Joe-Laptop.home>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>
	 <4AEF207C.9030002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1170 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755969AbZKBSQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 13:16:34 -0500
In-Reply-To: <4AEF207C.9030002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-02 at 13:10 -0500, William Allen Simpson wrote:
> Another style question:
> 
> +struct tcp_extend_values {
> +	u8				cookie_bakery[TCP_COOKIE_MAX];
> +	u8				cookie_plus;
> +	u8				cookie_in_always:1,
> +					cookie_out_never:1;
> +};
> +
> +static inline struct tcp_extend_values *tcp_xv(const struct request_values *rvp)
> +{
> +	return (struct tcp_extend_values *)rvp;
> +}
> 
> Some examples have "struct request_values" as the first element, others
> don't.  I started with it, and then removed it (as essentially nil).
> 
> Is there a preference?

I don't know, but I do have a bias against casting
const to non-const.

cheers, Joe




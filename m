From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2: add libgenl files
Date: Mon, 10 Sep 2012 09:55:18 -0700
Message-ID: <20120910095518.59ddae61@nehalam.linuxnetplumber.net>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg>
	<1347097705-2906-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2IJQzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:55:48 -0400
In-Reply-To: <1347097705-2906-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  8 Sep 2012 12:48:24 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> +
> +#define GENL_INIT_REQUEST(req, family, hdrsize, ver, cmd_, flags)	\
> +	do {								\
> +		memset(&req, 0, sizeof(req));				\
> +		req.n.nlmsg_type = family;				\
> +		req.n.nlmsg_flags = flags;				\
> +		req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + hdrsize);	\
> +		req.g.cmd = cmd_;					\
> +		req.g.version = ver;					\
> +	} while (0)
> +

Why not an inline function, macro code is error prone.

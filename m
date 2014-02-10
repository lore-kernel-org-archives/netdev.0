From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next-for-3.13 1/2] iplink: display slave
 information
Date: Mon, 10 Feb 2014 09:09:16 -0800
Message-ID: <20140210090916.34d4577e@nehalam.linuxnetplumber.net>
References: <20140210081146.6F4FEE5697@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:63391 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbaBJRJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 12:09:20 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so6460262pad.11
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 09:09:20 -0800 (PST)
In-Reply-To: <20140210081146.6F4FEE5697@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Feb 2014 09:11:46 +0100 (CET)
Michal Kubecek <mkubecek@suse.cz> wrote:

> +	if (1) {
> +		struct rtattr *attr[lu->maxslattr+1], **data = NULL;
> +
> +		if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
> +			parse_rtattr_nested(attr, lu->maxslattr,
> +					    linkinfo[IFLA_INFO_SLAVE_DATA]);
> +			data = attr;
> +		}
> +		lu->print_slave_opt(lu, fp, data);
> +	}
>  }

Ugly, please don't use if (1)

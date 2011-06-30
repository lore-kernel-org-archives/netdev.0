From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Thu, 30 Jun 2011 09:55:51 +0000 (UTC)
Message-ID: <iuhh76$fid$1@dough.gmane.org>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:53164 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab1F3J4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 05:56:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QcDyd-0003vm-V9
	for netdev@vger.kernel.org; Thu, 30 Jun 2011 11:56:03 +0200
Received: from 123.124.21.94 ([123.124.21.94])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 11:56:03 +0200
Received: from xiyou.wangcong by 123.124.21.94 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 11:56:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2011 12:40:10 -0700, Joe Perches wrote:

> Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> 
> Coalesce long formats.
...
> +		np->name, np->local_port);
> +	pr_info("%s: local IP %pI4\n",
> +		np->name, &np->local_ip);
> +	pr_info("%s: interface '%s'\n",
> +		np->name, np->dev_name);
> +	pr_info("%s: remote port %d\n",
> +		np->name, np->remote_port);
> +	pr_info("%s: remote IP %pI4\n",
> +		np->name, &np->remote_ip);
> +	pr_info("%s: remote ethernet address %pM\n", +		np->name,
> np->remote_mac);
>  }


This doesn't have much value, because the name of the netpoll
user (np->name) is already logged. If we changed it,
we would see "netconsole: netconsole: blah blah...".

Thanks.


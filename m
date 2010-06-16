From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] syncookies: check decoded options against
 sysctl settings
Date: Tue, 15 Jun 2010 18:09:47 -0700 (PDT)
Message-ID: <20100615.180947.241927235.davem@davemloft.net>
References: <1276464875-4460-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458Ab0FPBJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 21:09:36 -0400
In-Reply-To: <1276464875-4460-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 13 Jun 2010 23:34:35 +0200

> -	if (tcp_opt->sack_ok)
> -		tcp_sack_reset(tcp_opt);
> +	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
> +		return false;
>  

If you remove the tcp_sack_reset() call here, who is going to
do it?

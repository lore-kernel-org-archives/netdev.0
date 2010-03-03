From: Pavel Roskin <proski@gnu.org>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
	before dev_[mc/unicast]_[add/del]
Date: Wed, 03 Mar 2010 02:01:10 -0500
Message-ID: <20100303020110.hhu4cdecg08kkck0-cebfxv@webmail.spamcop.net>
References: <1267578048.14049.11.camel@mj>
	<20100303064001.GB2648@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:50255 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411Ab0CCHBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 02:01:10 -0500
In-Reply-To: <20100303064001.GB2648@psychotron.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Jiri Pirko <jpirko@redhat.com>:

> @@ -1734,7 +1738,7 @@ static int packet_mc_add(struct sock *sk,   
> struct packet_mreq_max *mreq)
>  		goto done;
>
>  	err = -EINVAL;
> -	if (mreq->mr_alen != dev->addr_len)
> +	if (mreq->mr_alen > dev->addr_len)
>  		goto done;
>
>  	err = -ENOBUFS;

The patch looks good, but did you mean to include this change?  It's  
not described.

-- 
Regards,
Pavel Roskin

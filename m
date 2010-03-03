From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
 before dev_[mc/unicast]_[add/del]
Date: Wed, 3 Mar 2010 08:36:03 +0100
Message-ID: <20100303073603.GD2648@psychotron.redhat.com>
References: <1267578048.14049.11.camel@mj>
 <20100303064001.GB2648@psychotron.redhat.com>
 <20100303020110.hhu4cdecg08kkck0-cebfxv@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257Ab0CCHgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 02:36:08 -0500
Content-Disposition: inline
In-Reply-To: <20100303020110.hhu4cdecg08kkck0-cebfxv@webmail.spamcop.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 03, 2010 at 08:01:10AM CET, proski@gnu.org wrote:
>Quoting Jiri Pirko <jpirko@redhat.com>:
>
>>@@ -1734,7 +1738,7 @@ static int packet_mc_add(struct sock *sk,
>>struct packet_mreq_max *mreq)
>> 		goto done;
>>
>> 	err = -EINVAL;
>>-	if (mreq->mr_alen != dev->addr_len)
>>+	if (mreq->mr_alen > dev->addr_len)
>> 		goto done;
>>
>> 	err = -ENOBUFS;
>
>The patch looks good, but did you mean to include this change?  It's
>not described.

Sure - this is revert of the bit from my original patch. I think it's clear from
description.

Jirka

>
>-- 
>Regards,
>Pavel Roskin

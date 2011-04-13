From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v3 2/3] sctp: Add ASCONF operation on the single-homed host
Date: Wed, 13 Apr 2011 10:32:27 +0900
Message-ID: <204CE840-C282-4B12-8015-37AD00386133@sfc.wide.ad.jp>
References: <02627A77-8793-4EEC-9540-F2DECBB8E23A@sfc.wide.ad.jp> <4DA4F8F9.2030302@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:60166 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932737Ab1DMBcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 21:32:32 -0400
In-Reply-To: <4DA4F8F9.2030302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

>> 
>> 
>> 	if (t)
>> 		asoc->peer.retran_path = t;
>> +	else if (unconfirmed)
>> +		asoc->peer.retran_path = t = unconfirmed;
>> 
>> 	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
>> 				 " %p addr: "
> 
> since we can not select unconfirmed transports for retransmission,
> this part is not correct. the specification forbids this due to security
> issues.
> Not sure whether you hit this bug: remove transport and left only
> one unconfirmed transport, it may cause oops while retransmit.
> I will send other patch to fix it first.
Yes, I added these 2 lines to avoid panic, I'll remove after your patch.  

Thanks,
- Michio
> 
> 
> ...snip...
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6: Fix the data length of get destination options
 with short length
Date: Wed, 28 May 2008 15:06:54 +0800
Message-ID: <483D048E.4000707@cn.fujitsu.com>
References: <483D0070.2090909@cn.fujitsu.com> <483D0194.5020908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	FNST-Wei Yongjun <yjwei@cn.fujitsu.com>,
	davem@sunset.davemloft.net
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62255 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbYE1HIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 03:08:02 -0400
In-Reply-To: <483D0194.5020908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Yang Hongyang said the following on 2008-5-28 14:49:
>> @@ -832,7 +832,7 @@ static int ipv6_getsockopt_sticky(struct
>>     len = min_t(unsigned int, len, ipv6_optlen(hdr));
>>     if (copy_to_user(optval, hdr, len))
>>         return -EFAULT;
>> -    return ipv6_optlen(hdr);
>> +    return len;
>> }
>>
> 
> Yang, your mail client broke tabs to blanks.
> Please resubmit.

--- net/ipv6/ipv6_sockglue.c	2008-05-28 09:17:14.000000000 +0800
+++ net/ipv6/ipv6_sockglue.c	2008-05-28 12:41:01.000000000 +0800
@@ -832,7 +832,7 @@ static int ipv6_getsockopt_sticky(struct
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
-	return ipv6_optlen(hdr);
+	return len;
 }



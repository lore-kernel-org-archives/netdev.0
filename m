From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/3] net: kill unused macros in head file
Date: Mon, 29 Nov 2010 16:21:14 +0800
Message-ID: <4CF3627A.1040401@cn.fujitsu.com>
References: <4CF34DEC.6090907@cn.fujitsu.com> <1291016563.7802.2.camel@takos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org,
	Patrick McHardy <kaber@trash.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61356 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751046Ab0K2IWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 03:22:54 -0500
In-Reply-To: <1291016563.7802.2.camel@takos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi yoshifuji-san:

YOSHIFUJI Hideaki wrote, at 11/29/2010 03:42 PM:
>>  
>> -#define RETRANS_TIMER	HZ
>> -
>>  #define MAX_RTR_SOLICITATIONS		3
>>  #define RTR_SOLICITATION_INTERVAL	(4*HZ)
>>  
> 
> I think we should use it in net/ipv6/addrconf.c,
> instead of magic number.

Do you mean to replace all HZ in net/ipv6/addrconf.c with RETRANS_TIMER?

HZ is also a macro. And I think HZ is more easier to read than RETRANS_TIMER.


-- 
Best Regards
-----
Shan Wei

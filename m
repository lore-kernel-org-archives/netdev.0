From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: kill unused macros in head file
Date: Wed, 01 Dec 2010 12:33:00 -0800 (PST)
Message-ID: <20101201.123300.35042706.davem@davemloft.net>
References: <4CF34DEC.6090907@cn.fujitsu.com>
	<1291016563.7802.2.camel@takos>
	<4CF3627A.1040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@trash.net
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756914Ab0LAUce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:32:34 -0500
In-Reply-To: <4CF3627A.1040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Mon, 29 Nov 2010 16:21:14 +0800

> Hi yoshifuji-san:
> 
> YOSHIFUJI Hideaki wrote, at 11/29/2010 03:42 PM:
>>>  
>>> -#define RETRANS_TIMER	HZ
>>> -
>>>  #define MAX_RTR_SOLICITATIONS		3
>>>  #define RTR_SOLICITATION_INTERVAL	(4*HZ)
>>>  
>> 
>> I think we should use it in net/ipv6/addrconf.c,
>> instead of magic number.
> 
> Do you mean to replace all HZ in net/ipv6/addrconf.c with RETRANS_TIMER?
> 
> HZ is also a macro. And I think HZ is more easier to read than RETRANS_TIMER.

These things currently say "1 * HZ" and "30 * HZ", so I think Hideaki's
request is reasonable.

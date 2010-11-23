From: David Miller <davem@davemloft.net>
Subject: Re: possible kernel oops from user MSS
Date: Mon, 22 Nov 2010 18:59:59 -0800 (PST)
Message-ID: <20101122.185959.193707855.davem@davemloft.net>
References: <4CDDC6EE.2010005@mvista.com>
	<20101112.152607.193708973.davem@davemloft.net>
	<4CEB2B8E.3090904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mzhang@mvista.com, netdev@vger.kernel.org
To: lyw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751260Ab0KWC7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 21:59:34 -0500
In-Reply-To: <4CEB2B8E.3090904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yewang <lyw@cn.fujitsu.com>
Date: Tue, 23 Nov 2010 10:48:46 +0800

> 
> 
> At 2010-11-13 7:26, David Miller wrote:
>> From: Min Zhang<mzhang@mvista.com>
>> Date: Fri, 12 Nov 2010 14:59:58 -0800
>>
>>> Regarding commit 7a1abd08d52fdeddb3e9a5a33f2f15cc6a5674d2 ("tcp:
>>> Increase TCP_MAXSEG socket option minimum"). What is the reason
>>> TCP_MAXSEG minimum be 64? Isn't the exact be 40 which is
>>> TCPOLEN_MD5SIG_ALIGNED(20) + TCPOLEN_TSTAMP_ALIGNED(12) + 8?
>>>
>>> Or is it better to use TCP_MIN_MSS from tcp.h:
>>>
>>> /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
>>> #define TCP_MIN_MSS        88U
>>
>> I suppose TCP_MIN_MSS would be better to use, I'll make that
>> change, thanks.
> 
>   David, do you have plan to fix this bug using TCP_MIN_MSS?

I will, it's deep in my backlog and pretty low priority right now.

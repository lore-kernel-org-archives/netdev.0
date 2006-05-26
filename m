From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Fri, 26 May 2006 11:35:53 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605261134250.18708@math.ut.ee>
References: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
 <Pine.SOC.4.61.0605260219270.13718@math.ut.ee> <20060526.104001.96071021.yoshfuji@linux-ipv6.org>
 <20060526.104245.106225873.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: pekkas@netcore.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:34300 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1750706AbWEZIgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 04:36:14 -0400
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060526.104245.106225873.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> (To YOSHIFUJI Hideaki: this is about the
>>> http://comments.gmane.org/gmane.linux.network/35262 thread)
> :
>> I guess rt6_select() is returning &ip6_null_entry and
>> the caller is finding next best route; e.g. default route.
>>
>> Does this solve your problem?
>
> Sorry, typo...

The unreachable route works now but LAN routing still does not work. 
Locally generated ICMPv6 packets that should go to LAN interface still 
go to tun6to4.

-- 
Meelis Roos (mroos@linux.ee)

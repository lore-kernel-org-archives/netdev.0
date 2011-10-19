From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 16:59:15 +0800
Message-ID: <4E9E9163.1090008@cn.fujitsu.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com> <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E9E2929.7070701@cn.fujitsu.com> <1318996187.19139.8.camel@edumazet-laptop> <4E9E5E1C.5020603@cn.fujitsu.com> <20111019072628.GS1830@secunet.com> <4E9E8552.1050405@cn.fujitsu.com> <20111019083832.GT1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54588 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752114Ab1JSI6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 04:58:48 -0400
In-Reply-To: <20111019083832.GT1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.10.19 16:38, Steffen Klassert wrote:
> On Wed, Oct 19, 2011 at 04:07:46PM +0800, Gao feng wrote:
>> 2011.10.19 15:26, Steffen Klassert wrote:
>>
>>>
>>> It is valid in the sense that we should not provide the user
>>> with a mtu information if we know that the value we got from
>>> the icmp packet ist bogus. But perhaps we can think about
>>> making the check for a valid mtu unconditionally and let
>>> ip_rt_frag_needed return a valid mtu in any case.
>>>
>>>
>>
>> I think we should return the pmtu in icmp packet to the raw socket,
>> and the valid mtu to tcp_v4_err or something else.
>>
> 
> Why you want to handle raw sockets different here?
> 

Return the pmtu in icmp packet to the raw socket,
let user space program to decide what to do.
BUT this is not important.

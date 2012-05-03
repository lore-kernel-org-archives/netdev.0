From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 4/6] tcp: Repair socket queues
Date: Thu, 03 May 2012 13:15:43 +0400
Message-ID: <4FA24CBF.3070806@parallels.com>
References: <4F901572.4040009@parallels.com>  <4F9015ED.7020607@parallels.com>  <1335957064.22133.428.camel@edumazet-glaptop>  <4FA248E4.7060501@parallels.com> <1336036120.10187.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16081 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2ECJPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:15:54 -0400
In-Reply-To: <1336036120.10187.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2012 01:08 PM, Eric Dumazet wrote:
> On Thu, 2012-05-03 at 12:59 +0400, Pavel Emelyanov wrote:
>> On 05/02/2012 03:11 PM, Eric Dumazet wrote:
> 
>>> I am not sure any check is performed on 'size' ?
>>
>> No, no checks here.
>>
>>> A caller might trigger OOM or wrap bug.
>>
>> Well, yes, but this ability is given to CAP_SYS_NET_ADMIN users only.
>> Do you think it's nonetheless worth accounting this allocation into
>> the socket's rmem?
> 
> Yes, something must be done...
> 
> Might be a good reason to un-inline tcp_try_rmem_schedule(), this fat
> thing...

OK, will try to look at it.

Thanks,
Pavel

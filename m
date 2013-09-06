From: Rick Jones <rick.jones2@hp.com>
Subject: Re: GSO/GRO and UDP performance
Date: Fri, 06 Sep 2013 09:42:17 -0700
Message-ID: <522A05E9.3090206@hp.com>
References: <52270659.1090208@openvpn.net> <1378295631.7360.98.camel@edumazet-glaptop> <52299EDD.1030208@openvpn.net> <1378472829.31445.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:11976 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab3IFQmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 12:42:19 -0400
In-Reply-To: <1378472829.31445.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2013 06:07 AM, Eric Dumazet wrote:
> On Fri, 2013-09-06 at 03:22 -0600, James Yonan wrote:
>
>> So I think that playing well with GSO/GRO is essential to get speedup in
>> UDP apps because of this 43x multiplier.
>>
>
> Thats not true. GRO cannot aggregate more than 16+1 packets.
>
> I think we cannot aggregate UDP packets, because UDP lacks sequence
> numbers, so reorders would be a problem.
>
> You really need something that is not UDP generic.

It may  not be as sexy, and it cannot get the 43x multiplier (just what 
*is* the service demand change on a netperf TCP_STREAM test these days 
between GSO/GRO on and off anyway?), but looking for basic path-length 
reductions would be goodness.

rick jones

From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 20:34:09 +0200
Message-ID: <4E135921.1060606@inliniac.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>  <1309846875.2720.43.camel@edumazet-laptop> <4E12B5A6.2020802@inliniac.net>  <1309849214.2720.45.camel@edumazet-laptop>  <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>  <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E133A09.8030907@inliniac.net>  <1309882999.2271.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E1346B7.4000105@inliniac.net> <1309890415.2545.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:49070 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab1GESeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:34:37 -0400
In-Reply-To: <1309890415.2545.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 08:26 PM, Eric Dumazet wrote:
>>>> What about a hashing scheme based on just the ip addresses? Would make
>>>> rxhash useless for this purpose, but would be a lot simpler overall maybe...
>>>>
>>>
>>> What about loads where a single IP address is used ?
>>
>> How would that be a problem?
> 
> Say I want my program able to process 2.000.000 packets per second on my
> 64 cpu machine, but one cpu is only able to process 100.000 pps.
> 
> All these packets are coming from IP1, and go to IP2, but thousand of
> different flows are in flight.
> 
> We need hash function taking into account source port and destination
> port.

Point taken. I see no other way either.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------


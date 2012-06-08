From: Rick Jones <rick.jones2@hp.com>
Subject: Re: netperf and endianness
Date: Thu, 07 Jun 2012 18:16:14 -0700
Message-ID: <4FD1525E.5020707@hp.com>
References: <20120607.180948.471478622905736125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:34951 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759498Ab2FHBQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 21:16:19 -0400
In-Reply-To: <20120607.180948.471478622905736125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2012 06:09 PM, David Miller wrote:
>
> Rick, I tried to use netperf between my x86-64 and sparc64 systems and
> nothing works.
>
> Does netperf do it's messaging in cpu byte order only?
>
> I don't see anything in netperf-2.5.x that translates into and out of
> network byte order :-/

David -

netperf sends things in network byte order.  It is all burried in 
send/recv_request and send/recv_response (in src/netlib.c).  Over the 
years I've run netperf between different endian systems with success. 
Chances are good that there is a netperf version mismatch between the 
sides - at least 99 times out of 10 that is what is happening when 
netperf doesn't work (other than with firewalls in place).

happy benchmarking,

rick jones

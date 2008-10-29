From: Rick Jones <rick.jones2@hp.com>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Wed, 29 Oct 2008 11:13:16 -0700
Message-ID: <4908A7BC.1060905@hp.com>
References: <20081022.221410.139436406.davem@davemloft.net>	<Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>	<20081024075938.0dddb745@extreme> <20081028.221351.172447876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	doug.leith@nuim.ie, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:30439 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbYJ2SNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:13:22 -0400
In-Reply-To: <20081028.221351.172447876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 24 Oct 2008 07:59:38 -0700
> 
> 
>>I was reading "Removing Exponential Backoff from TCP" by Mondal and
>>Kusmznovic at Northwesetern in ACM CCR. The paper tries to show that
>>nothing breaks by getting rid of backoff. Interestingly, FreeBSD
>>already doesn't do backoff until after 5th retry.
> 
> 
> Cell phone network folks want this (or something like it) too.

Wouldn't one get that by being able to tune TCP_RTO_MAX on some sort of 
basis (per dest perhaps)?

rick jones

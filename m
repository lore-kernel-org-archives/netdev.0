From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7] net: Batch inet_twsk_purge
Date: Thu, 03 Dec 2009 12:45:14 -0800
Message-ID: <m1ws13g52d.fsf@fess.ebiederm.org>
References: <1259843349-3810-7-git-send-email-ebiederm@xmission.com>
	<4B17BBC9.8070106@gmail.com> <m1ws14kwln.fsf@fess.ebiederm.org>
	<20091203.122436.239332194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca,
	dlezcano@fr.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45310 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbZLCUpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:45:15 -0500
In-Reply-To: <20091203.122436.239332194.davem@davemloft.net> (David Miller's message of "Thu\, 03 Dec 2009 12\:24\:36 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 03 Dec 2009 05:36:52 -0800
>
>> I think dccp may also need a inet_twsk_purge as well, but I couldn't
>> figure out what it was doing with timewait sockets.
>
> DCCP doesn't have time-wait sockets, it's more like UDP than TCP.

There is net/dccp/minisocks.c:dccp_time_wait that calls
inet_twsk_alloc().

So dccp is doing something with timewait sockets.

Eric


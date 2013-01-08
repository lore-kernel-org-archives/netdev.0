From: Einar Lueck <elelueck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V2] tcp: introduce raw access to experimental options
Date: Tue, 08 Jan 2013 15:36:35 +0100
Message-ID: <50EC2EF3.5080506@linux.vnet.ibm.com>
References: <1357575210-52926-1-git-send-email-elelueck@linux.vnet.ibm.com> <1357575210-52926-2-git-send-email-elelueck@linux.vnet.ibm.com> <1357577051.6919.3171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ubacher@de.ibm.com,
	raspl@de.ibm.com, frankbla@de.ibm.com, samudrala@us.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:48399 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756428Ab3AHOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 09:36:42 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Tue, 8 Jan 2013 14:35:55 -0000
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r08EaTbC55771238
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2013 14:36:29 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r08EaaZN003649
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2013 07:36:37 -0700
In-Reply-To: <1357577051.6919.3171.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2013 05:44 PM, Eric Dumazet wrote:
>
> Thats a big addition, and for example doesn't help if the SYNACK should
> include an option that is depending on the content of SYN message.
>
> For TCP fastopen for example, the cookie we send to the client is not a
> constant cookie.
>
> Also TCP coalescing of TCP collapse will merge several skbs, so storing
> "the last received options" in the socket is kind of not well defined
> semantic.
>
> It looks like you need to add hooks and kernel modules to fully use
> experimental options, like congestion control modules.
>
>
Thanks for the fast feedback, Eric. Let me try to make sure that I
understand your suggestions correctly:
You suggest to have a set of hooks that allow to move all code that
exploits experimental options into dedicated modules (e.g. one module
for TCP fastopen and one for cookies). Extensibility then comes on
a per module granularity. Is my understanding correct?

Thx,
Einar.

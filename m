From: Samir Bellabes <sbellabes@mandriva.com>
Subject: Re: [PATCH] Network Events Connector
Date: Thu, 05 Oct 2006 02:56:55 +0200
Message-ID: <m264ez60mg.fsf@cerbere.dyndns.info>
References: <m23ba7gscl.fsf@cerbere.dyndns.info>
	<20061002.133314.41657633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 188.235.97-84.rev.gaoland.net ([84.97.235.188]:13740 "EHLO
	cerbere.dyndns.info") by vger.kernel.org with ESMTP
	id S1751287AbWJEA55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 20:57:57 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061002.133314.41657633.davem@davemloft.net> (David Miller's
	message of "Mon, 02 Oct 2006 13:33:14 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Samir Bellabes <sbellabes@mandriva.com>
> Date: Mon, 02 Oct 2006 08:11:06 +0200
>
>> This patch adds a connector which reports networking's events to
>> userspace. It's sending events when a sock has its sk_state changed to :
>>   - LISTEN or CLOSE for DCCP and TCP
>>   - BIND or CLOSE for UDP.
>> 
> You can do this with the security layer, netfilter's ULOG, or even
> the netfilter connection tracking netlink sockets.
>
> That's 3 facilities by which you can accomplish this, and if none
> of them are perfect, add the small modifications you need to one
> of them to make them usable for your task.
>
> It makes no sense to add new facilities just for this.

I see, i will look futher the netfilter conntrack netlink sockets in
order to merge my code into it.
thanks for comments.

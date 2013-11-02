From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH net-next 1/1] ipv6: remove the destination condition on
 flow label sharing
Date: Sat, 02 Nov 2013 14:37:04 +0100
Message-ID: <52750000.10003@enst-bretagne.fr>
References: <1383322286-21464-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20131101214048.GD30284@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:47347 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474Ab3KBNq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Nov 2013 09:46:28 -0400
In-Reply-To: <20131101214048.GD30284@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Why?
> 
> Maybe I am not the only one up to date with recent advances in flow label
> management but I guess others want to know why, too?
> 

Actually, the good question is "why this restriction before". It
probably comes from the RFC 1809, an informational one:

RFC 1809 says:
> 
>    The specification further requires that all datagrams with the same
>    (non-zero) Flow Label must have the same Destination Address, Hop-
>    by-Hop Options header, Routing Header and Source Address contents.

In standard track RFCs (3697 / 6437), there are no restriction to set a
flow label to only one destination. In the same way, the condition on
IPv6 option is obsolete.


> Please reflect this in your changelog.
> 

I will send a V2.

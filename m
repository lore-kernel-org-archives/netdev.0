From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Thu, 02 Jul 2009 15:18:33 -0700
Message-ID: <m1y6r6wwxy.fsf@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
	<200907012201.13760.denys@visp.net.lb>
	<m11voyzu3y.fsf@fess.ebiederm.org>
	<200907030022.55186.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46152 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbZGBWSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:18:34 -0400
In-Reply-To: <200907030022.55186.denys@visp.net.lb> (Denys Fedoryschenko's message of "Fri\, 3 Jul 2009 00\:22\:55 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> If i have two networks proxy arp'ed
> 10.0.0.0/24 physical segment
> 10.0.1.0/24 physical segment
>
> proxy_arp host between them, so users can set on their laptops /22 and 
> communicate freely like they are in one segment.
>
> Some user with XP on laptop with ip 10.0.0.66/22 will come to 10.0.1.0/24 
> physical segment. As second he will turn on his laptop - proxy_arp host will 
> give him incorrect answer to his ARP announce "10.0.0.66 (ff:ff:ff:ff:ff:ff) 
> tell 10.0.0.66", it will tell "Reply 10.0.0.66 is-at 52:54:00:12:34:56" - 
> that IP is busy. And thats wrong. arp_proxy should help hosts to communicate, 
> but should not give incorrect answers that ip is taken.

The problem is you have machines on the wrong subnet.

If you are not enforcing which network your laptops are in you
want ethernet bridging not proxy_arp.

Eric


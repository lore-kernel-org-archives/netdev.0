From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 03 Jul 2009 17:46:15 -0700
Message-ID: <m163e9e0mg.fsf@fess.ebiederm.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907031402.34941.denys@visp.net.lb>
	<20090703.132005.113285172.davem@davemloft.net>
	<200907032337.16065.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48735 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZGDAqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 20:46:17 -0400
In-Reply-To: <200907032337.16065.denys@visp.net.lb> (Denys Fedoryschenko's message of "Fri\, 3 Jul 2009 23\:37\:15 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> On Friday 03 July 2009 23:20:05 David Miller wrote:
>
>> I really never should have applied your initial patch, I severely
>> regret it.  Thanksfully it's reverted now and we can look into
>> this issue more properly.
> If it was said before...
>
> Then maybe i will try to do some new sysctl value?
>
> By default it will be old behavior, but it can be changed to new on user 
> choice.
>
> Let's say 
>
> net.ipv4.arp_proxy_gateway 
> net.ipv4.arp_proxy_gratuitous

How do machines with addresses without routes to them
get packets from machines in other subnets?

Eric

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sat, 04 Jul 2009 08:00:58 -0700
Message-ID: <m1fxdc8pcl.fsf@fess.ebiederm.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907032337.16065.denys@visp.net.lb>
	<m163e9e0mg.fsf@fess.ebiederm.org>
	<200907041055.24516.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58712 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZGDPA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 11:00:59 -0400
In-Reply-To: <200907041055.24516.denys@visp.net.lb> (Denys Fedoryschenko's message of "Sat\, 4 Jul 2009 10\:55\:24 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> On Saturday 04 July 2009 03:46:15 Eric W. Biederman wrote:
>> Denys Fedoryschenko <denys@visp.net.lb> writes:
>> > On Friday 03 July 2009 23:20:05 David Miller wrote:
>> >> I really never should have applied your initial patch, I severely
>> >> regret it.  Thanksfully it's reverted now and we can look into
>> >> this issue more properly.
>> >
>> > If it was said before...
>> >
>> > Then maybe i will try to do some new sysctl value?
>> >
>> > By default it will be old behavior, but it can be changed to new on user
>> > choice.
>> >
>> > Let's say
>> >
>> > net.ipv4.arp_proxy_gateway
>> > net.ipv4.arp_proxy_gratuitous
>>
>> How do machines with addresses without routes to them
>> get packets from machines in other subnets?
>>
>> Eric
> ARP proxy generally was supposed to not export default route(by RFC and by 
> logic) it should be maybe other name, arp_proxy_no_default_gateway_export - 
> but i guess it is too long. With exporting default gateway i have two 
> choices - eat it and have answer to almost any ARP request, or loose for 
> proxy_arp completely this interface (by setting same medium id).
>
> Btw usually proxy_arp "answers" only for directly attached networks, e.g. link 
> layer routes (no gateway), but sure this is not a rule, and sometimes it is 
> even useful to "proxy" gatewayed routes. I am concerned only about 0.0.0.0/0 
> route, which is equal to wildcard.
>
> If i understand question correctly.

Problems occur when you have machines with ip addresses that you don't
have routes to.  How do machines with addresses without routes to them
get packets from machines in other subnets.

Eric



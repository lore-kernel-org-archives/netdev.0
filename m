From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 20:46:58 -0400 (EDT)
Message-ID: <20131028.204658.118867242681438729.davem@davemloft.net>
References: <1383002179.28991.14.camel@dcbw.foobar.com>
	<20131028.200810.66180312939474324.davem@davemloft.net>
	<20131029001340.GC26185@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3J2ArA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 20:47:00 -0400
In-Reply-To: <20131029001340.GC26185@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 29 Oct 2013 01:13:40 +0100

> On Mon, Oct 28, 2013 at 08:08:10PM -0400, David Miller wrote:
>> From: Dan Williams <dcbw@redhat.com>
>> Date: Mon, 28 Oct 2013 18:16:19 -0500
>> 
>> > On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
>> > First off, what's the reasoning behind having IPv6 privacy as a config
>> > option?  It's off-by-default and must be explicitly turned on, so is
>> > there any harm in removing the config?  Or is it just for
>> > smallest-kernel-ever folks?
>> 
>> I think it's for "smallest kernel ever" stuff.  Even every arch
>> defconfig that mentions it has it enabled :-)
>> 
>> Maybe it was optional initially because the code was new and
>> experimental'ish.  I don't know.
>> 
>> Regardless of the reason I think it only obfuscates the code with
>> ifdefs right now and I would be happy to see it disappear.
>> 
>> Any objections to this patch?
> 
> Yeah, I changed my mind. The ifdefs are really hideous. Fine for me.

Ok, pushed to net-next.

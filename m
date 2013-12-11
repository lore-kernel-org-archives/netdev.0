From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Wed, 11 Dec 2013 15:54:52 -0500 (EST)
Message-ID: <20131211.155452.558417595732985707.davem@davemloft.net>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com>
	<20131211192138.GB4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvlasenk@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3LKUyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:54:55 -0500
In-Reply-To: <20131211192138.GB4675@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 11 Dec 2013 20:21:38 +0100

> On Wed, Dec 11, 2013 at 12:45:14PM +0100, Denys Vlasenko wrote:
>> If ipv6 auto-configuration does not work, currently it's hard
>> to track what's going on. This change adds log messages
>> (at debug level) on every code path where ipv6 autoconf fails.
>> 
>> v2: fixed indentation in multi-line log output statements.
> 
> Have you seen lots of those problems? Some of those seem like very
> serious problems and maybe could also deserve a pr_warn or pr_err.
> 
> I hope these are one-time errors, so I don't think counters would
> be helpful.

I still think that statitics would better serve this issue.

For one thing, the event would always be counted, whereas with
pr_debug() someone has to turn on dynamic debugging in order
to see the message.

You can make them part of the per-inet6_dev MIB, and therefore
implicitly letting the admin know what interface the events
occurred on.

I would even prefer an approach involving signalling netlink
events in such circumstances with more detailed information.

Thanks.

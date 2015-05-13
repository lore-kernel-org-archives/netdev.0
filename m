From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] macvtap add missing ioctls - fix wrapping
Date: Wed, 13 May 2015 12:06:45 -0400 (EDT)
Message-ID: <20150513.120645.1183649099880232163.davem@davemloft.net>
References: <1431370810.3278.4.camel@myriabit.com>
	<20150512.230121.330638562727327262.davem@davemloft.net>
	<1431511561.3278.6.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbbEMQGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:06:48 -0400
In-Reply-To: <1431511561.3278.6.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Wed, 13 May 2015 11:06:01 +0100

> On Tue, 2015-05-12 at 23:01 -0400, David Miller wrote:
>> From: Justin Cormack <justin@myriabit.com>
>> Date: Mon, 11 May 2015 20:00:10 +0100
>> 
>> > The macvtap driver tries to emulate all the ioctls supported by a normal
>> > tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
>> > SIOCSIFHWADDR ioctls to get and set the mac address that are supported
>> > by tun/tap. This patch adds these.
>> > 
>> > Signed-off-by: Justin Cormack <justin@netbsd.org>
>> 
>> Applied to net-next, thanks.
>> 
> 
> The kbuild test picked up a stupid error, should I send a new patch
> version, or a patch against net-next?

Patches are never removable from my tree, so you must always send relative
fixes.

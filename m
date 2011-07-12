From: David Miller <davem@davemloft.net>
Subject: Re: netdevice: Kill 'feature' test macros.
Date: Tue, 12 Jul 2011 12:18:04 -0700 (PDT)
Message-ID: <20110712.121804.641426624646359493.davem@davemloft.net>
References: <20110712.105005.34046159802896038.davem@davemloft.net>
	<20110712111033.6e3923db@nehalam.ftrdhcpuser.net>
	<201107122106.21570.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab1GLTSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 15:18:12 -0400
In-Reply-To: <201107122106.21570.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 12 Jul 2011 21:06:21 +0200

> On Tuesday 12 July 2011 20:10:33 Stephen Hemminger wrote:
>> On Tue, 12 Jul 2011 10:50:05 -0700 (PDT)
>> David Miller <davem@davemloft.net> wrote:
>> 
>> > 
>> > Almost all of these have long outstayed their welcome.
>> > 
>> > And for every one of these macros, there are 10 features for which we
>> > didn't get macros added.
>> > 
>> > Let's just delete them all, and get out of habit of doing things this
>> > way.
>> > 
>> > Signed-off-by: David S. Miller <davem@davemloft.net>
>> 
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> This is sure to break out of tree drivers...
> 
> I guess that's a good thing, but it also breaks these:
> 
> drivers/staging/wlags49_h2/wl_internal.h:#ifdef HAVE_NETDEV_PRIV
> drivers/net/cxgb4vf/cxgb4vf_main.c:#ifdef HAVE_NET_DEVICE_OPS
> drivers/staging/ft1000/ft1000-usb/ft1000_hw.c:#ifdef HAVE_NET_DEVICE_OPS
> net/batman-adv/soft-interface.c:#ifdef HAVE_NET_DEVICE_OPS
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> 
> if the above are taken care of.

Thanks for catching this Arnd.

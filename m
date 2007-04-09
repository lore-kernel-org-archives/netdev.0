From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 22:11:29 +0200
Message-ID: <461A9DF1.8080904@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	<1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	<20070409.114402.45491411.davem@davemloft.net> <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, johannes@sipsolutions.net,
	jgarzik@pobox.com, containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43466 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965513AbXDIULv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:11:51 -0400
In-Reply-To: <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> The core mechanism for network configuration does not support creating
> virtual devices in a extensible reusable way.
> 
> In particular the tunnel types supported by iproute2 are hard coded
> into the user space tool and into the kernel interface.  The interface
> seems to be not the least bit extensible for creating new types of 
> non hardware backed network devices.


Yes, it sucks.

> So I don't see a readily usable mechanism for network configuration in
> netlink.


Thats why I suggested that we should create one, ideally before adding
more sysfs/proc/ioctl/... based interfaces, which we'll have a hard time
getting rid of again.

I could take care of this if you don't mind waiting until 2.6.23.

> The fact that netlink it uses unreliable packets and an
> asynchronous interface just adds to the difficulty in making use of
> it.


Its reliable on the userspace->kernel path as long as you don't use
MSG_DONTWAIT.

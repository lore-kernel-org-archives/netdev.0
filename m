From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 15:48:01 -0400
Message-ID: <461A9871.2060805@pobox.com>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	<1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	<20070409.114402.45491411.davem@davemloft.net> <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	akpm@linux-foundation.org, dim@openvz.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net, containers@lists.osdl.org,
	kuznet@ms2.inr.ac.ru, shemminger@linux-foundation.org,
	greearb@candelatech.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57358 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468AbXDITsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 15:48:17 -0400
In-Reply-To: <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Nor have I seen a rigorous adherence to all new network configuration
> using netlink.  The wireless code doesn't even seem to really try.

Not true:

> commit 711e2c33ac9221a419a9e28d05dd78a6a9c5fd4d
> Author: Jean Tourrilhes <jt@hpl.hp.com>
> Date:   Wed Feb 22 15:10:56 2006 -0800
> 
>     [PATCH] WE-20 for kernel 2.6.16
>     
>         This is version 20 of the Wireless Extensions. This is the
>     completion of the RtNetlink work I started early 2004, it enables the
>     full Wireless Extension API over RtNetlink.

Though this is/was pulled, and the upcoming mac80211 configuration 
interface should have netlink support.

This does not discount your other claims about netlink annoyances when 
used for interface configuration (unreliable, async, etc.), which I tend 
to agree with.

	Jeff



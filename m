From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add a missing unregister_pernet_subsys call
Date: Sun, 26 Sep 2010 19:10:02 -0700 (PDT)
Message-ID: <20100926.191002.68127432.davem@davemloft.net>
References: <20100924195552.GA8477@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757773Ab0I0CJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 22:09:42 -0400
In-Reply-To: <20100924195552.GA8477@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 24 Sep 2010 15:55:52 -0400

> Clean up a missing exit path in the ipv6 module init routines.  In
> addrconf_init we call ipv6_addr_label_init which calls register_pernet_subsys
> for the ipv6_addr_label_ops structure.  But if module loading fails, or if the
> ipv6 module is removed, there is no corresponding unregister_pernet_subsys call,
> which leaves a now-bogus address on the pernet_list, leading to oopses in
> subsequent registrations.  This patch cleans up both the failed load path and
> the unload path.  Tested by myself with good results.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.

Thanks a lot Neil.

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 18:34:26 +0900 (JST)
Message-ID: <20060829.183426.52410264.yoshfuji@linux-ipv6.org>
References: <20060829082435.GA2676@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbeulich@suse.de, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:1038 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964798AbWH2Jcf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:32:35 -0400
To: okir@suse.de
In-Reply-To: <20060829082435.GA2676@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060829082435.GA2676@suse.de> (at Tue, 29 Aug 2006 10:24:35 +0200), Olaf Kirch <okir@suse.de> says:

> When the Xen code configures the bridge device, this will do IPv6
> autoconfiguration for the interface, and since they use synthetic MAC
> addresses, there will be DAD collisions.
:
> The attached tentative patch makes IPv6 autoconf depend on the
> availability of IFF_MULTICAST. This is admittedly a bit of a hack, but
> it makes sense, since DAD and router solicitation do rely on multicast.

I disagree.  The node MUST NOT assign live address on
that interface.

Further analysis is needed, but one idea is to skip
addrconf_dev_config() if !(dev->flags & IFF_MULTICAST).

--yoshfuji


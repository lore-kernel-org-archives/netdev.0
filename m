From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 12:08:03 -0800
Message-ID: <13225.1234901283@death.nxdomain.ibm.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <200902172117.22671.arvidjaar@mail.ru>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, brian.haley@hp.com,
	netdev@vger.kernel.org,
	"J.A. =?iso-8859-1?q?Magall=F3n?=" <jamagallon@ono.com>,
	bonding-devel@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40036 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbZBQUIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 15:08:00 -0500
In-reply-to: <200902172117.22671.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andrey Borzenkov <arvidjaar@mail.ru> wrote:

>> If IPv6 is disable in kernel config bonding loads. But I think it is
>> regression, it should be possible to disable IPv6 if not required.
>
>This hard dependency was apparently introduced by this commit:
>
>commit 305d552accae6afb859c493ebc7d98ca3371dae2
>Author: Brian Haley <brian.haley@hp.com>
>Date:   Tue Nov 4 17:51:14 2008 -0800
>
>    bonding: send IPv6 neighbor advertisement on failover

	I'm not really sure how to work around this.  If bonding is
compiled with CONFIG_IPV6, then the IPv6 support is compiled in, and
bonding will need the ipv6 module loaded to resolve its symbols.

	The simple answer (don't turn on CONFIG_IPV6) isn't really
useful for the common case of distro kernels, which will generally have
CONFIG_IPV6 enabled.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

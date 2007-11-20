From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.25 1/4] include - Convert IP4 address class
	macros to inline functions
Date: Mon, 19 Nov 2007 21:59:58 -0800
Message-ID: <1195538398.4675.86.camel@localhost>
References: <1195055603.5163.179.camel@localhost>
	 <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
	 <20071119.214655.247082473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, jmorris@namei.org, kaber@coreworks.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2451 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755379AbXKTGAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:00:37 -0500
In-Reply-To: <20071119.214655.247082473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-19 at 21:46 -0800, David Miller wrote:
> I would also change the names, it's a better idea to prefix the
> names with a namespace for the stuff being operated on, therefore
> I'd prefer names like "ipv4_is_loopback()" etc.

I used:

+static inline bool is_ip4_loopback(__be32 addr)

and converted the current uses in net of macros
to use those functions directly.  I'd prefer to drop
the macros entirely, but there are uses in
drivers/infiniband and drivers/parisc to convert too.

> I'm dropping these patches for now.

Is the use of "is_ip4_<level>" not "ipv4_is_<level>"
your reason to drop the patches?



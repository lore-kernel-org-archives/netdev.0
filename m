From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 14:14:31 -0800 (PST)
Message-ID: <20090218.141431.103832064.davem@davemloft.net>
References: <20090218135537.GF3600@mini-me.lan>
	<06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com>
	<499C5486.5020807@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52880
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751877AbZBRWOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 17:14:47 -0500
In-Reply-To: <499C5486.5020807@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 18 Feb 2009 13:33:42 -0500

> Would a module parameter that disables ipv6 or at least addrconf be
> enough of a solution?

We have it, it's just that (as others have stated) it doesn't
prevent IPV6 sockets from being openned by applications.

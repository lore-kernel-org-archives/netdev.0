From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Assign linklocal addresses to isatap from link dev
Date: Wed, 04 Mar 2009 03:28:35 -0800 (PST)
Message-ID: <20090304.032835.183524465.davem@davemloft.net>
References: <200903010134.54405.mail@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mail@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750860AbZCDL2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:28:50 -0500
In-Reply-To: <200903010134.54405.mail@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <mail@saschahlusiak.de>
Date: Sun, 1 Mar 2009 01:34:48 +0100

> That way stateless autoconf works with isatap tunnels and without
> knowledge of the local v4 address.

This is not my understanding of how ISATAP works on hosts.

Real autoconf is not performed, but rather you must configure your
system with a PRL (potential routers list) and these routers are
probed periodically in order to keep track of which of them are still
functioning and also to perform a sort-of unicast-only autoconf.

I am pretty sure that the person who added the ISATAP code created the
current behavior intentionally.

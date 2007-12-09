From: David Miller <davem@davemloft.net>
Subject: Re: Bogus commit 70eba18b ("make bnx2x select ZLIB_INFLATE")?
Date: Sun, 09 Dec 2007 00:52:45 -0800 (PST)
Message-ID: <20071209.005245.241039796.davem@davemloft.net>
References: <adasl2ca7md.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	torvalds@linux-foundation.org, eliezert@broadcom.com,
	lee.schermerhorn@hp.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751772AbXLIIwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 03:52:46 -0500
In-Reply-To: <adasl2ca7md.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Sat, 08 Dec 2007 19:07:22 -0800

> Commit 70eba18b ("make bnx2x select ZLIB_INFLATE") in Linus's tree
> seems bogus.  As far as I can tell, bnx2x is not upstream yet, and the
> commit in question actually adds "select ZLIB_INFLATE" to the TEHUTI
> config, since there is no BNX2X config option (and also I don't see
> any reference to zlib in any tehuti files).
> 
> I assume this is some sort of merge problem that got added to the
> wrong tree and should be reverted upstream.

I already pointed this out to Jeff, here:

http://marc.info/?l=linux-netdev&m=119709982603567&w=2

Indeed, it needs to be fixed up.

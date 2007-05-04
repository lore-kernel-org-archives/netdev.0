From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Consolidate udp hash calculations
Date: Fri, 04 May 2007 12:39:09 -0700 (PDT)
Message-ID: <20070504.123909.88476080.davem@davemloft.net>
References: <463B4878.4060902@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161895AbXEDTjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:39:22 -0400
In-Reply-To: <463B4878.4060902@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Fri, 04 May 2007 18:51:36 +0400

> Make access to udphash/udplitehash symmetrical to inet hashes.
> 
> This may also help network namespaces, since they tend to use
> one hash for different namespaces by selecting the hash chain
> depending on a hash value and the namespace.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>

This is not the "UDP Hash Function", it is a mask to bring
the hash value modulo of the hash table size.

So your function name is misleading and makes the code
even worse.

I'm also not so sure this cleanup really adds any clarity,
even with a proper function name.

I can only assume you wish to do something with the UDP hash table
sizes, and therefore only want to have a need to touch one function.

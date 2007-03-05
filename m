From: David Miller <davem@davemloft.net>
Subject: Re: Fun splitting reassembled UDP skbuffs
Date: Sun, 04 Mar 2007 16:31:01 -0800 (PST)
Message-ID: <20070304.163101.51854724.davem@davemloft.net>
References: <14258.1173020015@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752573AbXCEAbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 19:31:02 -0500
In-Reply-To: <14258.1173020015@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Sun, 04 Mar 2007 14:53:35 +0000

> Is it possible to mix the likes of skb_clone(), pskb_pull() and pskb_trim()?

It should work, pskb_pull() and pskb_trim() check for cloning
and COW the data area as-needed.

I think you just have a refcounting error somewhere, based upon
your SLAB corruption trace.


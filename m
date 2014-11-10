From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Mon, 10 Nov 2014 00:20:20 -0500 (EST)
Message-ID: <20141110.002020.1062493586889118565.davem@davemloft.net>
References: <20141107221114.GB7996@ZenIV.linux.org.uk>
	<20141107234253.GE7996@ZenIV.linux.org.uk>
	<20141109211908.GF7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, mst@redhat.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbaKJFUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 00:20:23 -0500
In-Reply-To: <20141109211908.GF7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 9 Nov 2014 21:19:08 +0000

> 1) does sparc64 access_ok() need to differ for 32bit and 64bit tasks?

sparc64 will just fault no matter what kind of task it is.

It is impossible for a user task to generate a reference to
a kernel virtual address, as kernel and user accesses each
go via a separate address space identifier.

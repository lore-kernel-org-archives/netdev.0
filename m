From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 15:47:02 +1000
Message-ID: <20090427054702.GA15891@kryten>
References: <20090427030433.GA17454@kryten> <49F53FF6.2040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57722 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbZD0Fvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 01:51:51 -0400
Content-Disposition: inline
In-Reply-To: <49F53FF6.2040603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi,

> Then boot with rhash_entries = 8000 ?
> or 
> echo 1 >/proc/sys/net/ipv4/route/gc_interval

Yes we are hardwiring it for now.

> Sorry this limit is too small. Many of my customer machines would collapse.

So what would a reasonable upper limit be? Surely we should cap it at some
point?

Anton

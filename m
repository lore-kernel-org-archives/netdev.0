From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Wed, 5 Mar 2014 14:28:09 +1100
Message-ID: <20140305142809.64a71498@kryten>
References: <20140304210104.42ef3dd8@kryten>
	<20140304.134141.1732220919806520941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60330 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756070AbaCED2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 22:28:11 -0500
In-Reply-To: <20140304.134141.1732220919806520941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

> Alternatively you could just make unix_hash_fold() use csum_fold(),
> right?
> 
> static inline unsigned int unix_hash_fold(__wsum n)
> {
> 	unsigned int hash = (__force unsigned int) csum_fold(n);
> 
> 	hash ^= hash>>8;
> 	return hash&(UNIX_HASH_SIZE-1);
> }

Thanks, sounds good. Updated patch on the way.

Anton

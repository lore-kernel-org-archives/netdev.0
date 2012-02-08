From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [PATCH] IPoIB: Stop lying about hard_header_len and use skb->cb
 to stash LL addresses
Date: Wed, 8 Feb 2012 07:29:26 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373374C1C26@ORSMSX101.amr.corp.intel.com>
References: <CAG4TOxP2iEgT64L8vAR6P139U-HyHSxU8gdWw+cLsDwWSGkrwA@mail.gmail.com>
 <1328662281-16256-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"shlomop@mellanox.com" <shlomop@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49804 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab2BHH3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 02:29:39 -0500
In-Reply-To: <1328662281-16256-1-git-send-email-roland@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK, this works for me.  Definitely looks cleaner and also looks
> obvious enough that it's probably even correct.

I tested this with Dave's patch and Eric's first patch against Linus' latest tree 3.3-rc2+, and things look good so far.

Thanks,
- Sean

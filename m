From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 11:51:54 -0400 (EDT)
Message-ID: <20141015.115154.352769678083203819.davem@davemloft.net>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	<20141015.002514.384962932982389732.davem@davemloft.net>
	<c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, netdev@vger.kernel.org, LeoLi@freescale.com,
	linux-doc@vger.kernel.org
To: Jiafei.Pan@freescale.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Date: Wed, 15 Oct 2014 05:34:24 +0000

> Yes, for this matter, in order to do this we should modify the Ethernet
> drivers. For example, driver A want to driver B, C, D.. to support driver
> A's Hardware block access functions, so we have to modify driver B, C, D...
> It will be so complex for this matter.

Experience says otherwise.  It's three or four lines of code to attach
a page to an SKB frag.

The driver needs it's own buffer management and setup code anyways,
and no generic facility will replace that.

I think your precondition for these changes therefore doesn't really
exist.

Please, look over all of the drivers that exist already in the tree
and build SKBs using page frage from hardware device buffer pools.

You have to show us that all of those drivers can make use of your
facility.

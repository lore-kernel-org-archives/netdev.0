From: Anish Bhatt <anish@chelsio.com>
Subject: RE: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure
 caught with randconfig
Date: Tue, 12 Aug 2014 22:54:17 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D859F878@nice.asicdesigners.com>
References: <1407880481-22352-1-git-send-email-anish@chelsio.com>
	<20140812.152215.2300902059999669762.davem@davemloft.net>
	<525DB349B3FB5444AE057A887CB2A8D859F81B@nice.asicdesigners.com>,<20140812.154652.1490202340036045493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hch@infradead.org" <hch@infradead.org>,
	Karen Xie <kxie@chelsio.com>,
	Manoj Malviya <manojmalviya@chelsio.com>,
	"jim.epost@gmail.com" <jim.epost@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-228.uvs.sntcca.sbcglobal.net ([99.65.72.228]:21628
	"EHLO stargate.chelsio.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751301AbaHLWzI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 18:55:08 -0400
In-Reply-To: <20140812.154652.1490202340036045493.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Alternatively, depending upon what IPV6 interfaces you need to use
>in the cxgbi driver, you can potentially move them into the ipv6
>components we've split out to always be statically built into the
>kernel in order to avoid problems of this nature.  See the code
>linked in by the "obj-y +=" rule in net/ipv6/Makefile.

Got it, will fix accordingly.

>> This patch was based on code currently in net-next, and I presumed that would
>> be the correct way to go. I'll change it and rebase to net.

>The net-next tree isn't even open and active at this time, I said last week
>(as I do every single merge window) that I would explicitly announce on
>netdev when the net-next tree is openned.

No, I meant the fix I proposed is currently being used by other code already present in the 
kernel. I'll try and fix that as well.

>But, much more importantly, bug fixes for issues present in 'net'
>should always be targetted to the 'net' tree.

My bad, I was not aware this code made it back to net.

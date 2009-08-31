From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sk_free() should be allowed right after sk_alloc()
Date: Mon, 31 Aug 2009 05:02:20 -0700 (PDT)
Message-ID: <20090831.050220.255723045.davem@davemloft.net>
References: <4A9B7956.40507@gmail.com>
	<4A9B94B8.4050808@gmail.com>
	<20090831093019.GI5005@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbZHaMCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 08:02:06 -0400
In-Reply-To: <20090831093019.GI5005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 31 Aug 2009 09:30:19 +0000

> On Mon, Aug 31, 2009 at 11:15:36AM +0200, Eric Dumazet wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> 
>> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
>> (net: No more expensive sock_hold()/sock_put() on each tx)
>> sk_free() frees socks conditionally and depends
>> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
> 
> Very nice, but I hope David could fix btw. my "beeing" misspelling.

I will :-)

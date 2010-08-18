From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix a memmove bug in dev_gro_receive()
Date: Tue, 17 Aug 2010 17:37:56 -0700 (PDT)
Message-ID: <20100817.173756.193693195.davem@davemloft.net>
References: <F2E9EB7348B8264F86B6AB8151CE2D7920AD46E911@shsmsx502.ccr.corp.intel.com>
	<20100810083426.GA11509@ff.dom.local>
	<20100811120210.GA24019@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752334Ab0HRAhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 20:37:38 -0400
In-Reply-To: <20100811120210.GA24019@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Aug 2010 12:02:10 +0000

>>Xin Xiaohui wrote:
>> I looked into the code dev_gro_receive(), found the code here:
>> if the frags[0] is pulled to 0, then the page will be released,
>> and memmove() frags left.
>> Is that right? I'm not sure if memmove do right or not, but
>> frags[0].size is never set after memove at least. what I think
>> a simple way is not to do anything if we found frags[0].size == 0.
>> The patch is as followed.
> ...
> 
> This version of the patch fixes the bug directly in memmove.
> 
> Reported-by: "Xin, Xiaohui" <xiaohui.xin@intel.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied thanks a lot Jarek.

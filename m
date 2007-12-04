From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMC911X: Fix using of dereferenced skb after netif_rx
Date: Tue, 04 Dec 2007 09:49:50 +0100
Message-ID: <87r6i2yhch.fsf@macbook.be.48ers.dk>
References: <4753B74D.4070505@cn.fujitsu.com>
	<20071203101141.GA23549@gondor.apana.org.au>
	<4753D7F3.3050201@cn.fujitsu.com> <87wsrvyjob.fsf@macbook.be.48ers.dk>
	<4754B501.7070108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dustin McIntire <dustin@sensoria.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:27507 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbXLDIuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 03:50:13 -0500
Received: by mu-out-0910.google.com with SMTP id i10so680808mue
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 00:50:09 -0800 (PST)
In-Reply-To: <4754B501.7070108@cn.fujitsu.com> (Wang Chen's message of "Tue\, 04 Dec 2007 10\:01\:37 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wang" == Wang Chen <wangchen@cn.fujitsu.com> writes:

Hi,

 >> Why not simply update the stats before calling netif_rx as the return
 >> value isn't checked anyway?

 Wang> Even the return value of netif_rx isn't checked, dev->stats maybe
 Wang> changed in netif_rx. But fortunately dev->stats isn't changed in
 Wang> netif_rx.
 Wang> So, I agree. 
 Wang> Here is the new patch.

Thanks.

 Wang> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard

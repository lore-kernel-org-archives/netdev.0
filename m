From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during
 netdevice stats retrieval.
Date: Fri, 04 Sep 2015 16:15:59 -0700 (PDT)
Message-ID: <20150904.161559.86539633451623020.davem@davemloft.net>
References: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
	<20150904.152223.1146732101537643393.davem@davemloft.net>
	<20150904231105.GA3159@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org,
	vinschen@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934040AbbIDXQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:16:00 -0400
In-Reply-To: <20150904231105.GA3159@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 5 Sep 2015 01:11:05 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> Is there any reason we cannot allocate this DMA buffer at probe or
>> open time?
> 
> None.
> 
> As a fix for 6e85d5ad36a2 or as net-next material ?

I think we should just do it right to fix this bug, it's new to this
merge window anyways.

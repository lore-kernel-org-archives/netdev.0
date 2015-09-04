From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Sat, 5 Sep 2015 01:11:05 +0200
Message-ID: <20150904231105.GA3159@electric-eye.fr.zoreil.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150904.152223.1146732101537643393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org,
	vinschen@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57316 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933992AbbIDXLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:11:41 -0400
Content-Disposition: inline
In-Reply-To: <20150904.152223.1146732101537643393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Is there any reason we cannot allocate this DMA buffer at probe or
> open time?

None.

As a fix for 6e85d5ad36a2 or as net-next material ?

-- 
Ueimor

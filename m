From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 17 Dec 2013 21:44:45 -0800
Message-ID: <1387345485.19078.299.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
	 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B133C6.8070409@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:42173 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3LRFoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:44:46 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so7806344pdj.9
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:44:46 -0800 (PST)
In-Reply-To: <52B133C6.8070409@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 13:33 +0800, Fan Du wrote:

> Hi Eric
> 
> Thanks for your attention,
> I'm not follow why xchg here is unsafe, could you please elaborate a bit more?

Read include/linux/llist.h and llist_add_batch() implementation,
it will be very clear why your implementation is not safe.

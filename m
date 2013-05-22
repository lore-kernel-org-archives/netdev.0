From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tg3: Fix boot code initialization
 handshake bug
Date: Wed, 22 May 2013 14:51:46 -0700 (PDT)
Message-ID: <20130522.145146.147229466788853844.davem@davemloft.net>
References: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3EVVvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 17:51:47 -0400
In-Reply-To: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Tue, 21 May 2013 15:57:31 -0700

> This patch fixes an issue that was recently observed on one platform after few
> hundred suspend/resume loops. The code has existed since day one and affects
> every tg3 device. Due to the scope of the devices affected, submitting this
> patch to net-next to let it bake for sometime before submitting to stable.

If it's suitable for -stable, it has to be suitable for 'net', so that's
where I applied it.

This really isn't complicated.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Thu, 15 Aug 2013 01:07:26 -0700 (PDT)
Message-ID: <20130815.010726.719593168454341579.davem@davemloft.net>
References: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	shangw@linux.vnet.ibm.com, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab3HOIH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:07:27 -0400
In-Reply-To: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Tue, 13 Aug 2013 11:45:13 -0700

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> Commit d8af4dfd8 ("net/tg3: Fix kernel crash") introduced a possible
> NULL pointer dereference in tg3 driver when !netdev || !netif_running(netdev)
> condition is met and netdev is NULL. Then, the jump to the 'done' label
> calls dev_close() with a netdevice that is NULL. Therefore, only call
> dev_close() when we have a netdevice, but one that is not running.
> 
> [ Add the same checks in tg3_io_slot_reset() per Gavin Shan - by Nithin
> Nayak Sujir ]
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> Cc: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>

Can I get some reviews from the Broadcom folks?

Thanks.

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Thu, 15 Aug 2013 08:15:20 -0700
Message-ID: <1376579720.9648.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
 <20130815.010726.719593168454341579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, netdev@vger.kernel.org, dborkman@redhat.com,
	shangw@linux.vnet.ibm.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4616 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab3HOPP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 11:15:27 -0400
In-Reply-To: <20130815.010726.719593168454341579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-15 at 01:07 -0700, David Miller wrote: 
> From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
> Date: Tue, 13 Aug 2013 11:45:13 -0700
> 
> > From: Daniel Borkmann <dborkman@redhat.com>
> > 
> > Commit d8af4dfd8 ("net/tg3: Fix kernel crash") introduced a possible
> > NULL pointer dereference in tg3 driver when !netdev || !netif_running(netdev)
> > condition is met and netdev is NULL. Then, the jump to the 'done' label
> > calls dev_close() with a netdevice that is NULL. Therefore, only call
> > dev_close() when we have a netdevice, but one that is not running.
> > 
> > [ Add the same checks in tg3_io_slot_reset() per Gavin Shan - by Nithin
> > Nayak Sujir ]
> > 
> > Reported-by: Dave Jones <davej@redhat.com>
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> > Cc: Michael Chan <mchan@broadcom.com>
> > Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> Can I get some reviews from the Broadcom folks?
> 

We worked with Daniel at Red Hat and Gavin at IBM on this patch.
Thanks.

Signed-off-by: Michael Chan <mchan@broadcom.com>

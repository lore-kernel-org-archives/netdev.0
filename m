From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/5] pktgen: set different default min_pkt_size for
 different protocols
Date: Wed, 10 Oct 2012 10:19:47 +0800
Message-ID: <1349835587.2864.5.camel@cr0>
References: <1349777131-4425-1-git-send-email-amwang@redhat.com>
	 <1349777131-4425-2-git-send-email-amwang@redhat.com>
	 <20121009.135531.554326230925730938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607Ab2JJCTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 22:19:52 -0400
In-Reply-To: <20121009.135531.554326230925730938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 13:55 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue,  9 Oct 2012 18:05:28 +0800
> 
> > ETH_ZLEN is too small for IPv6, so this default value is not
> > suitable.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> pkt_dev->max_pkt_size is no longer being initialized.
> 
> At least set it to whatever you compute in pkt_dev->min_pkt_size

Oops, I forgot it. Will send an updated version.

Thanks!

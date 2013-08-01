From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: rename CONFIG_NET_LL_RX_POLL to
 CONFIG_NET_RX_BUSY_POLL
Date: Thu, 01 Aug 2013 09:53:55 +0800
Message-ID: <1375322035.7780.0.camel@cr0>
References: <1375177125-7209-1-git-send-email-amwang@redhat.com>
	 <51F9128F.6030700@linux.intel.com>
	 <20130731.170103.1728448549547059368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab3HAByD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 21:54:03 -0400
In-Reply-To: <20130731.170103.1728448549547059368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 17:01 -0700, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Wed, 31 Jul 2013 16:35:11 +0300
> 
> > On 30/07/2013 12:38, Cong Wang wrote:
> >> From: Cong Wang <amwang@redhat.com>
> >> 
> >> Eliezer renames several *ll_poll to *busy_poll, but forgets
> >> CONFIG_NET_LL_RX_POLL, so in case of confusion, rename it too.
> >> 
> >> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> >> Cc: David S. Miller <davem@davemloft.net>
> >> Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > Looks OK to me, but I'm not able to test it since I'm away on vacation.
> > If you can test it with the usual config options and allnoconfig, then I
> > have no objections to this patch.

I tested with CONFIG_NET_RX_BUSY_POLL=y and CONFIG_NET_RX_BUSY_POLL=n.

> > 
> > If you want me to test it, that can only happen early next week.
> 
> Cong, you missed Documentation/sysctl/net.txt, please fix that up and
> respin this patch.
> 

OK, will do.

Thanks.

From: Thomas Graf <tgraf@suug.ch>
Subject: Re: ProxyARP and IPSec
Date: Fri, 8 Sep 2006 09:37:03 +0200
Message-ID: <20060908073703.GR3470@postel.suug.ch>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060824105037.GL3470@postel.suug.ch> <45009D02.10700@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50409 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750700AbWIHHgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 03:36:43 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
Content-Disposition: inline
In-Reply-To: <45009D02.10700@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* H. Peter Anvin <hpa@zytor.com> 2006-09-07 15:28
> Thomas Graf wrote:
> >What about adding blackhole device to be used for such routes.
> >I believe it would be good architecture to always use devices
> >to state directions packets are being received from and sent to.
> 
> The dummy device can be used for that.

I was thinking a bit beyond that, a device similiar to ifb but
without a hard header to allow classification. Packets get
enqueued before skb->dst gets overwritten with dst->child and
dequeue handles the second half of xfrm4_output_finish2().

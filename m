From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 4 Aug 2008 06:51:43 +0000
Message-ID: <20080804065143.GA6643@ff.dom.local>
References: <20080801101929.GA12735@ff.dom.local> <20080803.182524.240976246.davem@davemloft.net> <20080804062813.GA4570@ff.dom.local> <20080803.234200.193697269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:3387 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbYHDGqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 02:46:20 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1376568wri.5
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2008 23:46:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080803.234200.193697269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 03, 2008 at 11:42:00PM -0700, David Miller wrote:
...
> > -#ifdef CONFIG_NET_CLS_ACT
> > -/* additional qdisc xmit flags */
> > +/* additional qdisc xmit flags (NET_XMIT_MASK in linux/netdevice.h) */
> >  enum net_xmit_qdisc_t {
> > -	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
> > +	__NET_XMIT_STOLEN = 0x0001FFFF,
> > +	__NET_XMIT_BYPASS = 0x0002FFFF,
> >  };
> >  
> 
> Please, respin both patches, so that the "NET_XMIT_MASK + 1"
> construct doesn't ever exist in the tree.

OK, I'll soon respin this all!

Jarek P.

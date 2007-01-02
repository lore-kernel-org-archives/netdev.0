From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Tue, 2 Jan 2007 09:23:02 +0100
Message-ID: <20070102082302.GB1712@ff.dom.local>
References: <45889C53.8000307@candelatech.com> <4599E6D5.6050207@candelatech.com> <20070102073909.GA1712@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:42642 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932973AbXABIV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 03:21:26 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <20070102073909.GA1712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 02, 2007 at 08:39:09AM +0100, Jarek Poplawski wrote:
...
> It is hard to say what kind of bug to expect
> because at the same time other net_rx_action
> with the same vlan dev could take place on
> other processor and this inetdev_init could
> do more.

Sorry! inetdev_init couldn't do more because
of rtnl lock but anyway the rest should be valid:

> The main thing is the possibility of processing
> skb with not entirely open source dev which isn't
> expected (and checked) by receive functions.
> I think the easiest way to convince yourself is
> to add temporarily IFF_UP flag checking with
> dropping at the beginning of netif_receive_skb and
> __vlan_hwaccel_rx.

Jarek P.

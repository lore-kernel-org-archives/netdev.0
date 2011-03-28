From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] netxen: fix LRO disable warning
Date: Mon, 28 Mar 2011 07:17:46 +0200
Message-ID: <20110328051744.GA2275@redhat.com>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
 <1300704474.2884.66.camel@edumazet-laptop>
 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
 <20110327.180818.39174806.davem@davemloft.net>
 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8849@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751662Ab1C1GSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 02:18:16 -0400
Content-Disposition: inline
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8849@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2011 at 12:33:43AM -0500, Amit Salecha wrote:
> > >> > netxen_nic_set_flags() rejects data if other flag than
> > ETH_FLAG_LRO
> > >> is set.
> > >> > Driver also supports NETIF_F_HW_VLAN_TX.
> > >> > Now compare data with ethtool_op_get_flags(), to get all supported
> > >> features.
> > >> >
> > >> > Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
> > >> > Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> > >> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > >> > ---
> > >>
> > >> Hmm, it would be really nice you provide more information for stable
> > >> teams.
> > >>
> > >> If I am not mistaken, bug was introduced in 2.6.36 ?
> > >>
> > > No, It was introduced in 2.6.37, when ETH_FLAG_TXVLAN and
> > ETH_FLAG_RXVLAN introduced.
> > > Yes it should also make into 2.6.37.4 stable kernel.
> >
> > Applied, but 2.6.37.x maintainence has ceased so there is no point
> > worrying about this patch for that stable branch any longer.

2.6.38 needs that fix as well ...

> I thought you will apply patch from Stanislaw Gruszka (net: fix ethtool->set_flags not intended -EINVAL return value), which is more generic and takes care of all drivers.
> 
> David, you are not cc in that patch. I will forward you, in case you miss it.

Patch is here:
http://patchwork.ozlabs.org/patch/88060/

I could also repost rebased patch if needed.

Stanislaw

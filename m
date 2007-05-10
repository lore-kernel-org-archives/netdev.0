From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Thu, 10 May 2007 08:39:08 +0200
Message-ID: <20070510063908.GA2021@ff.dom.local>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local> <20070509093536.GA2436@ff.dom.local> <001801c79275$80cd5e00$0701010a@note> <20070510053052.GA1611@ff.dom.local> <049301c792c8$ecdf4c40$0202fea9@Jura>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	paulus@samba.org, greearb@candelatech.com, mostrows@speakeasy.net,
	davem@davemloft.net
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:32923 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755733AbXEJGcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 02:32:45 -0400
Content-Disposition: inline
In-Reply-To: <049301c792c8$ecdf4c40$0202fea9@Jura>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 10:03:23AM +0400, Yuriy N. Shkandybin wrote:
> Yes, there is no real lockup with pppoe
> ll repeat my configuration:
> vpn (pptp(mostly)+pppoe) concentrator
> PPPoE provided through 802.1q
> +OSPF (quagga)

I think, it's a little too general... Probably at least
ifconfig and ip rule, route etc. could tell something.
But let's wait a little.

Jarek P.

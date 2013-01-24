From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve
 proformance
Date: Wed, 23 Jan 2013 22:39:18 -0800
Message-ID: <20130124063917.GA27481@ppwaskie-mobl2.amr.corp.intel.com>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
 <1358922071.12374.743.camel@edumazet-glaptop>
 <CAHrpEqTqSfBCpoMZ9S81VoXWgVK1iOR+e2OasARgbTD8m_RRvw@mail.gmail.com>
 <1358948954.12374.758.camel@edumazet-glaptop>
 <CAHrpEqSk8bs8552qQ6j_iP9=QNN98NSd1p+TQN=naRr-NUaxkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, s.hauer@pengutronix.de
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54617 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab3AXGkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 01:40:31 -0500
Content-Disposition: inline
In-Reply-To: <CAHrpEqSk8bs8552qQ6j_iP9=QNN98NSd1p+TQN=naRr-NUaxkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 10:26:00AM +0800, Frank Li wrote:
> > A NAPI driver must call netif_receive_skb(), especially if
> > the RX path does a full copy of the frame : Its hot in cpu cache and
> > should be processed at once.
> 
> How about napi_gro_receive? is it correct function? I found many driver use it.

If you want to coalesce your Rx frames to reduce overhead, then yes.  It's
a good performance improvement overall.

-PJ

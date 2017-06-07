From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: fix xfrm_dev_event() missing when compile
 without CONFIG_XFRM_OFFLOAD
Date: Wed, 7 Jun 2017 12:59:02 +0200
Message-ID: <20170607105902.GU2631@secunet.com>
References: <1496277502-10642-1-git-send-email-liuhangbin@gmail.com>
 <1496300276-30901-1-git-send-email-liuhangbin@gmail.com>
 <20170606080658.GO2631@secunet.com>
 <20170606092600.GC12974@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Guy Shapiro <guysh@mellanox.com>,
        David Miller <davem@davemloft.net>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35284 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751008AbdFGK7G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 06:59:06 -0400
Content-Disposition: inline
In-Reply-To: <20170606092600.GC12974@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 05:26:01PM +0800, Hangbin Liu wrote:
> On Tue, Jun 06, 2017 at 10:06:58AM +0200, Steffen Klassert wrote:
> > On Thu, Jun 01, 2017 at 02:57:56PM +0800, Hangbin Liu wrote:
> > > In commit d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API") we
> > > make xfrm_device.o only compiled when enable option CONFIG_XFRM_OFFLOAD.
> > > But this will make xfrm_dev_event() missing if we only enable default XFRM
> > > options.
> > > 
> > > Then if we set down and unregister an interface with IPsec on it.
> > 
> > You should not be able to register an interface with IPsec offload
> > without CONFIG_XFRM_OFFLOAD.
> 
> Yes, I mean when compile with default CONFIG_XFRM, the xfrm_dev_event() ->
> xfrm_dev_down() -> xfrm_garbage_collect() will missing.

Ok, I see what you mean now. Thanks for the explanation!

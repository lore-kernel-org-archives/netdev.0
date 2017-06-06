From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: fix xfrm_dev_event() missing when compile
 without CONFIG_XFRM_OFFLOAD
Date: Tue, 6 Jun 2017 10:06:58 +0200
Message-ID: <20170606080658.GO2631@secunet.com>
References: <1496277502-10642-1-git-send-email-liuhangbin@gmail.com>
 <1496300276-30901-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Guy Shapiro <guysh@mellanox.com>,
        David Miller <davem@davemloft.net>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46330 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750881AbdFFIHB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:07:01 -0400
Content-Disposition: inline
In-Reply-To: <1496300276-30901-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 02:57:56PM +0800, Hangbin Liu wrote:
> In commit d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API") we
> make xfrm_device.o only compiled when enable option CONFIG_XFRM_OFFLOAD.
> But this will make xfrm_dev_event() missing if we only enable default XFRM
> options.
> 
> Then if we set down and unregister an interface with IPsec on it.

You should not be able to register an interface with IPsec offload
without CONFIG_XFRM_OFFLOAD.

> there
> will no xfrm_garbage_collect(), which will cause dev usage count hold and
> get error like:
> 
> unregister_netdevice: waiting for <dev> to become free. Usage count = 4

Can you explain how to reproduce this?

From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a device independent napi
 instance
Date: Fri, 27 Jan 2017 07:59:39 +0100
Message-ID: <20170127065939.GL30338@gauss.secunet.com>
References: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
 <1485413456-31197-3-git-send-email-steffen.klassert@secunet.com>
 <1485440767.5145.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1485443422.5145.132.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38806 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754037AbdA0HLE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 02:11:04 -0500
Content-Disposition: inline
In-Reply-To: <1485443422.5145.132.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 07:10:22AM -0800, Eric Dumazet wrote:
> On Thu, 2017-01-26 at 06:26 -0800, Eric Dumazet wrote:
> 
> > 
> > Alternative would be to use a 
> > 
> > static struct net_device xfrm_napi_anchor_device;
> > 
> > and use gro_cell
> 
> Also take a look at init_dummy_netdev()

I already thought about using some dummy net_device for this,
but was not sure what I need to initialize. So it seemed
to be safer to use a private napi instance.

init_dummy_netdev() is exactly what I need for that, thanks a lot!

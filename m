From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH net] mcs7780: Silence uninitialized variable warning
Date: Mon, 31 Jul 2017 10:41:40 +0300
Message-ID: <20170731070925.ztlfbyd7pvoz46wh@mwanda>
References: <20170728144511.tf7nc672hwo35rnn@mwanda>
 <20170729.232855.1831311386560187695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29198 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdGaHmY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:42:24 -0400
Content-Disposition: inline
In-Reply-To: <20170729.232855.1831311386560187695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 29, 2017 at 11:28:55PM -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 28 Jul 2017 17:45:11 +0300
> 
> > -	__u16 rval;
> > +	__u16 rval = -1;
> 
> Fixing a bogus warning by assigning a signed constant to an
> unsigned variable doesn't really make me all that happy.
> 
> I don't think I'll apply this, sorry.

There's no guarantee that small kmallocs will always succeed in future
kernels so it's not *totally* bogus.

regards,
dan carpenter

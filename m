From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][net-next] esp6: fix incorrect null pointer check on xo
Date: Wed, 19 Apr 2017 07:20:49 +0200
Message-ID: <20170419052048.GC15917@secunet.com>
References: <20170418140653.8839-1-colin.king@canonical.com>
 <20170418.131253.2065320027211688167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <colin.king@canonical.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40902 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759671AbdDSFVA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 01:21:00 -0400
Content-Disposition: inline
In-Reply-To: <20170418.131253.2065320027211688167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 01:12:53PM -0400, David Miller wrote:
> From: Colin King <colin.king@canonical.com>
> Date: Tue, 18 Apr 2017 15:06:53 +0100
> 
> Trimming the CC: list down to something that actually makes
> sense.
> 
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > The check for xo being null is incorrect, currently it is checking
> > for non-null, it should be checking for null.
> > 
> > Detected with CoverityScan, CID#1429349 ("Dereference after null check")
> > 
> > Signed-off-by: Colin Ian King <colin.king@canonical.com>

I've added

Fixes: 7862b4058b9f ("esp: Add gso handlers for esp4 and esp6")

and applied it to ipsec-next, thanks!

> 
> At a minimum you should work to check that you are CC:'ing the person
> who added the code you are fixing.  You can use "git blame" for this.
> 
> Also, Steffen, you need to add the new IPSEC offload files to the
> MAINTAINERS entry for iPSEC.

Yes, will do a patch.

From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec: Fix dst leak in xfrm_bundle_create().
Date: Wed, 11 Oct 2017 13:54:30 +0200
Message-ID: <20171011115430.GL3149@secunet.com>
References: <20171010.205938.2305003344238226004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53012 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752197AbdJKLyd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 07:54:33 -0400
Content-Disposition: inline
In-Reply-To: <20171010.205938.2305003344238226004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 08:59:38PM -0700, David Miller wrote:
> 
> If we cannot find a suitable inner_mode value, we will leak
> the currently allocated 'xdst'.
> 
> The fix is to make sure it is linked into the chain before
> erroring out.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> Steffen, I found this via visual inspection.  Please double check my
> work before applying this :-)

Looks good. Patch applied, thanks David!

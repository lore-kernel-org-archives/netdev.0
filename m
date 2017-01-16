From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: state: fix potential null pointer dereference on
 afinfo
Date: Mon, 16 Jan 2017 14:27:04 +0100
Message-ID: <20170116132704.GQ3541@gauss.secunet.com>
References: <20170113140703.20961-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38680 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751672AbdAPN1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 08:27:12 -0500
Content-Disposition: inline
In-Reply-To: <20170113140703.20961-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 02:07:03PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> afinfo is being null checked before a call afinfo->init_tempsel
> so afinfo may be potentially null. ifinfo may still be null in
> the case were it is not updated when family == tmpl->encap_family,
> hence we may hit a null pointer dereference in the call to
> afinfo->init_temprop.
> 
> Fix this by adding a null ptr check before calling init_temprop.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

I've applied already a fix for this from Florian Westphal.

Thanks a lot anyway!

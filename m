From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] net: ip, diag -- Adjust raw_abort to use unlocked
 __udp_disconnect
Date: Tue, 1 Nov 2016 23:58:28 +0300
Message-ID: <20161101205828.GB1852@uranus.lan>
References: <20161101200500.GA1852@uranus.lan>
 <1478033554.7065.356.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36207 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcKAU6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 16:58:32 -0400
Content-Disposition: inline
In-Reply-To: <1478033554.7065.356.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 01:52:34PM -0700, Eric Dumazet wrote:
> 
> The preferred way to cite a bug origin is :
> 
> Fixes: 286c72deabaa ("udp: must lock the socket in udp_disconnect()")

Aha. Thank you, will do this way next time.

> > CC: David S. Miller <davem@davemloft.net>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: David Ahern <dsa@cumulusnetworks.com>
> > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > CC: James Morris <jmorris@namei.org>
> > CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> > CC: Patrick McHardy <kaber@trash.net>
> > CC: Andrey Vagin <avagin@openvz.org>
> > CC: Stephen Hemminger <stephen@networkplumber.org>
> 
> That is a lot of CC ...

Because I CC'ed all for raw diag first patch, so I thought I've
to notify them with this typo in code.

> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks.
> 
> 

	Cyrill

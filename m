From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v4] gso: Support partial splitting at the
 frag_list pointer
Date: Fri, 9 Sep 2016 08:46:45 +0200
Message-ID: <20160909064645.GW31137@gauss.secunet.com>
References: <20160908113307.GT31137@gauss.secunet.com>
 <CAKgT0UdieQO3KM1ZdcyczsO7+uNe-fDg9=jkDg-25nuQyiG56A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Marcelo Ricardo Leitner" <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57412 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752218AbcIIGqu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 02:46:50 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UdieQO3KM1ZdcyczsO7+uNe-fDg9=jkDg-25nuQyiG56A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 08:37:47AM -0700, Alexander Duyck wrote:
> 
> A few minor things.
> 
> First you somehow got a couple spaces in the line before gso_size.
> That is why the two lines above don't line up.
> 
> Second it occurred to me that we could have a situation where tail is
> equal to segs in the case of GSO_PARTIAL with an MSS aligned frame.
> To avoid doing duplicate division we might want to make the else an
> "else if (tail != segs)"
> 
> Finally I think the value for the division should be tail->len -
> doffset, not tail->len as we shouldn't include the header data in the
> size as it might cause us to report more packets then we actually
> generate.
> 
> I think that should cover all of it.  Sorry for the thrash.

Never mind, I do a v5. Better one more iteration of review than a
suboptimal patch.

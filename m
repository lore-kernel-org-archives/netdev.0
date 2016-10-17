From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 15:25:06 +0200
Message-ID: <1476710706.315.2.camel@sipsolutions.net>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
         <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
         <1476696226.19992.13.camel@sipsolutions.net>
         <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com>
         <1476696918.19992.15.camel@sipsolutions.net>
         <67161BCC-596E-4DDE-A58E-9195BB5570C2@linaro.org>
         <1476698041.19992.19.camel@sipsolutions.net>
         <41D0AC2F-E86E-4A98-AD8B-1239D7E6123A@linaro.org>
         <CAKv+Gu9OT6r3gbrLi_wzBcPXoA6K9z=-4ybrgQy4X=FvjOOuhA@mail.gmail.com>
         <1476710169.315.1.camel@sipsolutions.net>
         <CAKv+Gu_jdiQn+o5PAZmPfMsQYt8PsOkDE6YNU11VH9WM_QPcvg@mail.gmail.com>
         (sfid-20161017_152040_808548_79392877)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50428 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754730AbcJQNZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 09:25:10 -0400
In-Reply-To: <CAKv+Gu_jdiQn+o5PAZmPfMsQYt8PsOkDE6YNU11VH9WM_QPcvg@mail.gmail.com> (sfid-20161017_152040_808548_79392877)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Indeed. And it keeps the clutter inside the aes_xxx.c files, which
> could easily be updated in the future to use some auxdata feature if
> it ever materializes.
> 
> I think it would help this code, but also the ESP code you pointed
> out, to have some kind of 'ordered synchronous' CRYPTO_xxx flag,
> where the crypto API could manage the kmem cache and percpu pointers
> to allocations.

Yeah, could be useful to have that more generally.

>  This goes well beyond what we can do as a fix, though, so we need an
> intermediate solution in any case.
> 
> Shall I propose the patch?

I assume you mean a mac80211 patch - sure, I'll take that instead of
the two I have now.

johannes

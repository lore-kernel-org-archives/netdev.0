From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 15:46:32 +0200
Message-ID: <1476452792.31114.46.camel@sipsolutions.net>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org>
         <1476450635.31114.42.camel@sipsolutions.net>
         <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com>
         <1476450941.31114.45.camel@sipsolutions.net>
         <CAKv+Gu81RYq1aZUQ2Aru3Vev4LGgb1zFwWz8gepE0tQEhQi9Uw@mail.gmail.com>
         (sfid-20161014_151923_585451_B0D65F1F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59080 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756349AbcJNNqm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 09:46:42 -0400
In-Reply-To: <CAKv+Gu81RYq1aZUQ2Aru3Vev4LGgb1zFwWz8gepE0tQEhQi9Uw@mail.gmail.com> (sfid-20161014_151923_585451_B0D65F1F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Is the aad[] actually reused? I would assume it only affects the mac
> on encryption, and the verification on decryption but I don't think
> we actually need it back from the crypto routines.

I don't think it's reused.

> Exactly what you said above :-) My patch only touches CCM but as you
> said,
> 
> """
> 'Also there's B_0/J_0 for CCM/GCM, and the 'zero' thing that GMAC
> has.
> """

Ah, but we can/should do the same for the others, no?

johannes

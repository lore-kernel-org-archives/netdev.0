From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 15:15:41 +0200
Message-ID: <1476450941.31114.45.camel@sipsolutions.net>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org>
         <1476450635.31114.42.camel@sipsolutions.net>
         <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com>
         (sfid-20161014_151311_047575_C7571920)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com> (sfid-20161014_151311_047575_C7571920)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-14 at 14:13 +0100, Ard Biesheuvel wrote:
> 
> > But if we allocate things anyway, is it worth expending per-CPU
> > buffers on these?
> 
> Ehmm, maybe not. I could spin a v2 that allocates a bigger buffer,
> and copies aad[] into it as well

Copies in/out, I guess. Also there's B_0/J_0 for CCM/GCM, and the
'zero' thing that GMAC has.

> That does not help the other algos though

What do you mean?

johannes

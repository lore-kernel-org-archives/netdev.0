From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Thu, 27 Apr 2017 14:04:14 +0200
Message-ID: <CAHmME9oa3LYsnBgguxFqbJwps1ai=cuHHEgSpfY36AQHAN5r1Q@mail.gmail.com>
References: <20170425155215.4835-1-Jason@zx2c4.com> <20170425184734.26563-1-Jason@zx2c4.com>
 <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com> <20170427113016.GA12448@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        kernel-hardening@lists.openwall.com,
        David Miller <davem@davemloft.net>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:45241 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034002AbdD0MET (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 08:04:19 -0400
In-Reply-To: <20170427113016.GA12448@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 1:30 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Hmm, I think this can actually happen:

Alright, perhaps better to err on the side of caution, then.

Jason

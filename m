From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] macsec: avoid heap overflow in skb_to_sgvec
Date: Tue, 25 Apr 2017 17:13:39 +0200
Message-ID: <CAHmME9rZ29X=R-quViXaEO_ouxeB2EpzR2bkR93rrN4n--QDqw@mail.gmail.com>
References: <20170421211448.16995-1-Jason@zx2c4.com> <20170425145340.GA25241@bistromath.localdomain>
 <CAHmME9ovUDJRDA+Td4Y0bfQZEG5pZQo1JC0nYDVqWMOdxAe5kQ@mail.gmail.com> <20170425151248.GB25241@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425151248.GB25241@bistromath.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 5:12 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>> https://patchwork.ozlabs.org/patch/754861/
>
> Yes, that prevents the overflow, but now you're just dropping
> packets.

Right, it's a so-called "defense-in-depth" measure.

> I'll review that later, let's fix the overflow without
> breaking connectivity for now.

Agreed.

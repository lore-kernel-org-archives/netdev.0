From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 7/8] net: Rename TCA*BPF_DIGEST to ..._SHA256
Date: Wed, 11 Jan 2017 01:50:49 +0100
Message-ID: <58758169.2020408@iogearbox.net>
References: <cover.1484090585.git.luto@kernel.org> <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@kernel.org>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/2017 12:24 AM, Andy Lutomirski wrote:
> This makes it easier to add another digest algorithm down the road if
> needed.  It also serves to force any programs that might have been
> written against a kernel that had the old field name to notice the
> change and make any necessary changes.
>
> This shouldn't violate any stable API policies, as no released kernel
> has ever had TCA*BPF_DIGEST.

Imho, this and patch 6/8 is not really needed. Should there ever
another digest alg be used (doubt it), then you'd need a new nl
attribute and fdinfo line anyway to keep existing stuff intact.
Nobody made the claim that you can just change this underneath
and not respecting abi for existing applications when I read from
above that such apps now will get "forced" to notice a change.

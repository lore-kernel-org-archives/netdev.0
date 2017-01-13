From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 7/8] net: Rename TCA*BPF_DIGEST to ..._SHA256
Date: Sat, 14 Jan 2017 00:08:30 +0100
Message-ID: <58795DEE.3090403@iogearbox.net>
References: <cover.1484090585.git.luto@kernel.org> <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org> <58758169.2020408@iogearbox.net> <CALCETrUHenMS1iomFr7+YEy_M3zaotrWbfMe93=BmzCbzJ0fLw@mail.gmail.com> <5875F65A.4010904@iogearbox.net> <CALCETrVhuszdsfayLrBBkSzJ+A3m+hJjdZQWDj9FOg+2UB_ZBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrVhuszdsfayLrBBkSzJ+A3m+hJjdZQWDj9FOg+2UB_ZBw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/2017 07:19 PM, Andy Lutomirski wrote:
> On Wed, Jan 11, 2017 at 1:09 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
[...]
>> Ok. Sleeping over this a bit, how about a general rename into
>> "prog_tag" for fdinfo and TCA_BPF_TAG resp. TCA_ACT_BPF_TAG for
>> the netlink attributes, fwiw, it might reduce any assumptions on
>> this being made? If this would be preferable, I could cook that
>> patch against -net for renaming it?
>
> That would be fine with me.
>
> I think there are two reasonable approaches to computing the actual tag.
>
> 1. Use a standard, modern cryptographic hash.  SHA-256, SHA-512,
> Blake2b, whatever.  SHA-1 is a bad choice in part because it's partly
> broken and in part because the implementation in lib/ is a real mess
> to use (as you noticed while writing the code).
>
> 2. Use whatever algorithm you like but make the tag so short that it's
> obviously not collision-free.  48 or 64 bits is probably reasonable.
>
> The intermediate versions are just asking for trouble.

Yeah agree, I've just sent a patch to rework this a bit and it got
also reasonably small for net. Cleanups, if needed, can be done in
net-next once that's pulled into it.

Thanks,
Daniel

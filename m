From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 7/8] net: Rename TCA*BPF_DIGEST to ..._SHA256
Date: Wed, 11 Jan 2017 10:09:46 +0100
Message-ID: <5875F65A.4010904@iogearbox.net>
References: <cover.1484090585.git.luto@kernel.org> <f284a4d87cde103cd78de64b8607e3c80a17e2e5.1484090585.git.luto@kernel.org> <58758169.2020408@iogearbox.net> <CALCETrUHenMS1iomFr7+YEy_M3zaotrWbfMe93=BmzCbzJ0fLw@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUHenMS1iomFr7+YEy_M3zaotrWbfMe93=BmzCbzJ0fLw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

On 01/11/2017 04:11 AM, Andy Lutomirski wrote:
> On Tue, Jan 10, 2017 at 4:50 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 01/11/2017 12:24 AM, Andy Lutomirski wrote:
>>>
>>> This makes it easier to add another digest algorithm down the road if
>>> needed.  It also serves to force any programs that might have been
>>> written against a kernel that had the old field name to notice the
>>> change and make any necessary changes.
>>>
>>> This shouldn't violate any stable API policies, as no released kernel
>>> has ever had TCA*BPF_DIGEST.
>>
>> Imho, this and patch 6/8 is not really needed. Should there ever
>> another digest alg be used (doubt it), then you'd need a new nl
>> attribute and fdinfo line anyway to keep existing stuff intact.
>> Nobody made the claim that you can just change this underneath
>> and not respecting abi for existing applications when I read from
>> above that such apps now will get "forced" to notice a change.
>
> Fair enough.  I was more concerned about prerelease iproute2 versions,
> but maybe that's a nonissue.  I'll drop these two patches.

Ok. Sleeping over this a bit, how about a general rename into
"prog_tag" for fdinfo and TCA_BPF_TAG resp. TCA_ACT_BPF_TAG for
the netlink attributes, fwiw, it might reduce any assumptions on
this being made? If this would be preferable, I could cook that
patch against -net for renaming it?

Thanks,
Daniel

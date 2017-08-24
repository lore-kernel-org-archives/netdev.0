From: Nick Desaulniers <ndesaulniers@google.com>
Subject: Re: [PATCH v2] netfilter: nf_nat_h323: fix logical-not-parentheses warning
Date: Thu, 24 Aug 2017 09:25:41 -0700
Message-ID: <CAKwvOdk35Bd4KRsW2+45BXO9ja_-NhFkdymNxMSEmtrf1CM6Og@mail.gmail.com>
References: <20170811174259.GA3743@salvia> <20170811181607.33878-1-ndesaulniers@google.com>
 <CAKwvOdmw+bnN-nKeKbE8WJJ8Enc4PCeC3KD5KpaSVOT4+ycDKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthias Kaehlcke <mka@chromium.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKwvOdmw+bnN-nKeKbE8WJJ8Enc4PCeC3KD5KpaSVOT4+ycDKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bumping for review (resending, had gmail set to html mode)

On Mon, Aug 14, 2017 at 10:36 AM, Nick Desaulniers
<ndesaulniers@google.com> wrote:
> Minor nit for the commit message that can get fixed up when being merged:
>
> On Fri, Aug 11, 2017 at 11:16 AM, Nick Desaulniers
> <ndesaulniers@google.com> wrote:
>
>> if (x)
>>   return
>> ...
>>
>> rather than:
>>
>> if (!x == 0)
>
> should remove the `!`, ex:
>
> if (x == 0)
>
>>   ...
>> else
>>   return
>
> --
> Thanks,
> ~Nick Desaulniers



-- 
Thanks,
~Nick Desaulniers

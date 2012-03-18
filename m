From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: netfilter: Hung task
Date: Sun, 18 Mar 2012 22:52:55 +0200
Message-ID: <CA+1xoqcQYqCgQb=1M5PVkm=6SBhV2oJxJ2CtBp=gAvZM36Kc2Q@mail.gmail.com>
References: <CA+1xoqfCTXxXsbfUjttuOVutyD_FzYS8PoOoAOOtB72P8SwdVg@mail.gmail.com>
 <20120318141943.GA28850@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kaber@trash.net, davem@davemloft.net,
	Dave Jones <davej@redhat.com>, netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120318141943.GA28850@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 18, 2012 at 4:19 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Sun, Mar 18, 2012 at 12:55:13PM +0200, Sasha Levin wrote:
>> Hi all,
>>
>> I got the following spew after fuzzing using trinity on a KVM tools
>> guest, using the latest linux-next.
>>
>> It reminds me a lot of https://lkml.org/lkml/2012/3/14/375 and
>> https://lkml.org/lkml/2012/1/14/45
>
> You mention neither Linux kernel version nor the way you trigger this.
>
> With that little information it's really hard to really know.

Hum? I've mentioned it happened with "the latest linux-next" (which is
currently two days old), and using the trinity fuzzer - which means
that I don't have a specific method to reproduce the problem.

> Time ago we applied this to Netfilter which is already in mainline:
>
> http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=70e9942f17a6193e9172a804e6569a8806633d6b

FWIW, that patch is part of linux-next.

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Thu, 4 Dec 2014 07:56:54 -0800
Message-ID: <CAADnVQJawht6+sARaP=s9PyPERjrVOBKiJLrCK0OwnLtzT2CAA@mail.gmail.com>
References: <CAADnVQK3iui8cAmhi28=65p2CJbTu45fR98ri8Uh8xLRb=cwnA@mail.gmail.com>
	<1417032059.16355.4.camel@perches.com>
	<063D6719AE5E284EB5DD2968C1650D6D1C9FDA63@AcuExch.aculab.com>
	<1417114175.4305.3.camel@perches.com>
	<1417685187.2721.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417685187.2721.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 4, 2014 at 1:26 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2014-11-27 at 10:49 -0800, Joe Perches wrote:
>> On Thu, 2014-11-27 at 12:25 +0000, David Laight wrote:
>> > Why the change in data?
>>
>> btw: without gcov and using -O2
>>
>> $ size arch/x86/net/bpf_jit_comp.o*
>>    text          data     bss     dec     hex filename
>>    9671             4       0    9675    25cb arch/x86/net/bpf_jit_comp.o.new
>>   10679             4       0   10683    29bb arch/x86/net/bpf_jit_comp.o.old
>
> Alexei?
>
> Is this 10% reduction in size a good reason to change the code?

yes.
I believe you're seeing it with gcc 4.9. I wanted to double
check what 4.6 and 4.7 are doing. If they're not suddenly
increase code size then resubmit it for inclusion please.

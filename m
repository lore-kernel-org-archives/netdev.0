From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Thu, 30 Mar 2017 19:34:16 +0530
Message-ID: <CAHgaXdKfbob3WHMho32JSh_dmfp2A=cjcePqk+NfajVpShPE6Q@mail.gmail.com>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
 <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
 <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com>
 <20170315.145512.1542025976162251828.davem@davemloft.net> <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com>
 <58DAF908.8010404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
	Mircea Gherzan <mgherzan@gmail.com>, Network Development <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org,
	ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <kernel-hardening-return-7189-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <58DAF908.8010404@iogearbox.net>
List-Id: netdev.vger.kernel.org

Thanks Daniel.

Can you tell me how to test the eBPF JIT compiler? It would be great
if you could tell me starting from compiling to proper testing.
Best,
Shubham Bansal


On Wed, Mar 29, 2017 at 5:30 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Hi Shubham,
>
> On 03/28/2017 10:49 PM, Shubham Bansal wrote:
> [...]
>>
>> Do you have any document to understand the working of tail calls? I
>> looked at your presentations but it seemed confusing to me. Anything
>> simple would be great, just about the tail calls. I don't think I need
>> examples, I can get them from your presentations. I just need a very
>> general idea. May be you know the code in kernel where it is
>> implemented.
>
>
> Sure, it's in __bpf_prog_run(), see the JMP_TAIL_CALL (kernel/bpf/core.c
> +1019).
> That's effectively what JITs implement. [1] page 3 has a high-level
> description
> as well, hope that helps.
>
> Thanks,
> Daniel
>
>   [1]
> http://www.netdevconf.org/1.1/proceedings/papers/On-getting-tc-classifier-fully-programmable-with-cls-bpf.pdf

From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Wed, 29 Mar 2017 02:19:54 +0530
Message-ID: <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com>
 <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com>
 <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com> <20170315.145512.1542025976162251828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>, Daniel Borkmann <daniel@iogearbox.net>,
	Mircea Gherzan <mgherzan@gmail.com>, Network Development <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <kernel-hardening-return-7131-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170315.145512.1542025976162251828.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

Thanks David. It helped a lot.

Hi Daniel,

Do you have any document to understand the working of tail calls? I
looked at your presentations but it seemed confusing to me. Anything
simple would be great, just about the tail calls. I don't think I need
examples, I can get them from your presentations. I just need a very
general idea. May be you know the code in kernel where it is
implemented.
Thanks for the help Daniel.

Best,
Shubham Bansal


On Thu, Mar 16, 2017 at 3:25 AM, David Miller <davem@davemloft.net> wrote:
> From: Shubham Bansal <illusionist.neo@gmail.com>
> Date: Wed, 15 Mar 2017 17:43:44 +0530
>
>>> You can't truncate, but you'll have to build 64-bit ops using 32-bit registers.
>>
>> A small example would help a lot.
>
> You can simply perform 64-bit operations in C code and see what gcc
> outputs for that code on this 32-bit target.

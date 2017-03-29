From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Wed, 29 Mar 2017 02:00:08 +0200
Message-ID: <58DAF908.8010404@iogearbox.net>
References: <CAHgaXd+EKJ0FWaaPojsNJtgY_YpdQXu6eMEp97uOpTFAWs4qTQ@mail.gmail.com> <CAGXu5jLo8UvpNSQZBHjWZoO959ha6KFQxFzmg7SK44wz=R_QSg@mail.gmail.com> <CAHgaXdJL92XRjHae2Nb9j9SerSe65=N=ErDHTQf23sdBxwthzw@mail.gmail.com> <20170315.145512.1542025976162251828.davem@davemloft.net> <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Mircea Gherzan <mgherzan@gmail.com>,
 Network Development <netdev@vger.kernel.org>,
 kernel-hardening@lists.openwall.com,
 linux-arm-kernel@lists.infradead.org, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <kernel-hardening-return-7145-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHgaXd+4QkFxnt-_iCqH8AyCN_Y8gXwr+y=iugz38NKSWspsbA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi Shubham,

On 03/28/2017 10:49 PM, Shubham Bansal wrote:
[...]
> Do you have any document to understand the working of tail calls? I
> looked at your presentations but it seemed confusing to me. Anything
> simple would be great, just about the tail calls. I don't think I need
> examples, I can get them from your presentations. I just need a very
> general idea. May be you know the code in kernel where it is
> implemented.

Sure, it's in __bpf_prog_run(), see the JMP_TAIL_CALL (kernel/bpf/core.c +1019).
That's effectively what JITs implement. [1] page 3 has a high-level description
as well, hope that helps.

Thanks,
Daniel

   [1] http://www.netdevconf.org/1.1/proceedings/papers/On-getting-tc-classifier-fully-programmable-with-cls-bpf.pdf

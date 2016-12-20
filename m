From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 21:26:22 -0800
Message-ID: <CALCETrXY4f4Fbxv+d4QV-Tfhbc0-tJUnXph6uAdMAOofy116RQ@mail.gmail.com>
References: <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <20161219.203422.500916400463091702.davem@davemloft.net>
 <CALCETrUc-iDUT8isKc43PPZ3xz31Sz+QTU+_SQQTAsWhH+zkLw@mail.gmail.com> <20161220045155.GC86803@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Andrew Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161220045155.GC86803@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 8:51 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Dec 19, 2016 at 05:40:53PM -0800, Andy Lutomirski wrote:
>>
>> By the way, even if Alexei is right, the BPF_PROG_DETACH API doesn't
>> even take a reference to a BPF program as an argument.  What is it
>> supposed to do if this mechanism ever gets extended?
>
> we just add another field to that anonymous union just like
> we did for other commands and everything is backwards compatible.
> It's the basics of bpf syscall that we've been relying on for some
> time now and it worked just fine.

And what happens if you don't specify that member and two programs are attached?

--Andy

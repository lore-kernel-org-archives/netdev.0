From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v10 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sat, 6 Sep 2014 09:04:23 -0700
Message-ID: <CAMEtUuxPynQ4wdWDgCU+9_3_GRYn8oA4f-emcF+mqiQdLsqEWg@mail.gmail.com>
References: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
	<1409894238-9055-3-git-send-email-ast@plumgrid.com>
	<20140906141051.GA4245@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34314 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaIFQEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 12:04:25 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so730121wib.15
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 09:04:23 -0700 (PDT)
In-Reply-To: <20140906141051.GA4245@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 6, 2014 at 7:10 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Sep 04, 2014 at 10:17:18PM -0700, Alexei Starovoitov wrote:
>> allow user space to generate eBPF programs
>>
>> uapi/linux/bpf.h: eBPF instruction set definition
>>
>> linux/filter.h: the rest
>>
>> This patch only moves macro definitions, but practically it freezes existing
>> eBPF instruction set, though new instructions can still be added in the future.
>>
>> These eBPF definitions cannot go into uapi/linux/filter.h, since the names
>> may conflict with existing applications.
>>
>> Full eBPF ISA description is in Documentation/networking/filter.txt
>
> I think you need to have at least one single interface using this
> before you can expose it to userspace. So this should come in the
> small batch that introduces the first interface of your ebpf code in
> userspace. AFAIK, this has been the policy so far.

That's what I've been doing over the last year.
My first eBPF patch was in Sep of 2013!
since then I've been only tweaking and massaging it.
Nothing fundamentally changed.
Last few month I've been posting these series with not only
first user, but with multiple. Many examples, test cases and so on.
The series became big and Dave asked to split them.
Please see the cover letter. These two patches is stage I.
More examples and use cases in stage II, stage III, stage IV, etc
All these patches are ready. I'm only submitting them one at
a time to make review easier.
Please see them in my tree if you interested.

Thanks

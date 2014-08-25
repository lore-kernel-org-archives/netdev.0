From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: x86: add missing 'shift by register'
 instructions to x64 eBPF JIT
Date: Mon, 25 Aug 2014 12:43:24 -0700
Message-ID: <CAMEtUuzGYPc82NoaGzSs3sFve3C0oWGxnZ5yYjtFTcPc0pmsnw@mail.gmail.com>
References: <1408994822-14929-1-git-send-email-ast@plumgrid.com>
	<53FB90F7.1000701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:51248 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbaHYTnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:43:25 -0400
Received: by mail-we0-f181.google.com with SMTP id k48so13528604wev.26
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:43:24 -0700 (PDT)
In-Reply-To: <53FB90F7.1000701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 12:39 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 08/25/2014 09:27 PM, Alexei Starovoitov wrote:
>>
>> 'shift by register' operations are supported by eBPF interpreter, but were
>> accidently left out of x64 JIT compiler. Fix it and add a testcase.
>>
>> Reported-by: Brendan Gregg <brendan.d.gregg@gmail.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
>> ---
>>
>> Probably not worth sending to stable, but wouldn't hurt either.
>
>
> Then I guess this should be against -net tree then.
>
> I guess implications were only fallback to interpreter, right?

yes. it falls back to interpreter and works fine.
I'm not sure it's worth sending to stable that's why I went with net-next.
Technically it's half missing feature and half bug.
It feels more of missing feature to me.

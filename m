From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] bpf: Enable BPF JIT on ppc32
Date: Mon, 16 Feb 2015 10:02:40 -0500
Message-ID: <CAADnVQJ2kONF03avXmcvKpwTaZ74wOLzcTjTOLKt1=XoY01Yqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@lists.ozlabs.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Alexei Starovoitov <ast@kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34136 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbbBPPDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 10:03:01 -0500
Received: by mail-qc0-f171.google.com with SMTP id l6so24498129qcy.2
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 07:03:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 2:13 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> On 2/15/15, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 02/15/2015 07:06 PM, Denis Kirjanov wrote:
>>> This patch series enables BPF JIT on ppc32. There are relatevily
>>> few chnages in the code to make it work.
>>>
>>> All test_bpf tests passed both on 7447a and P2041-based machines.
>>
>> I'm just wondering, next to the feedback that has already been
>> provided, would opening this up for ppc32 make it significantly
>> more difficult in future to migrate from classic BPF JIT to eBPF
>> JIT eventually (which is what we want long-term)? Being curious,
>> is there any ongoing effort from ppc people?
>>
>
> Well, I don't see significant challenges to enable eBPF on ppc64 in the future.
> I'll start working on it after I get this merged

sounds great. looking forward to it :)

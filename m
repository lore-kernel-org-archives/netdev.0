From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Tue, 1 Nov 2016 16:04:35 -0600
Message-ID: <CAADnVQ+u5Q=+275nQCeHN2grk+kmRke9uJmMjRarA92UG7uGsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: joe@ovn.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Wang Nan <wangnan0@huawei.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36688 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbcKAWE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 18:04:58 -0400
Received: by mail-lf0-f65.google.com with SMTP id o20so3853329lfg.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 15:04:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 9:48 AM, David Miller <davem@davemloft.net> wrote:
> From: Joe Stringer <joe@ovn.org>
> Date: Mon, 31 Oct 2016 11:39:14 -0700
>
>> Update tools/lib/bpf to provide more functionality and improve interoperation
>> with other tools that generate and use eBPF code.
>>
>> The kernel uapi headers are a bit newer than the version in the tools/
>> directory; synchronize those.
>>
>> samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
>> tools/lib/bpf/bpf* with these functions to bring them into parity.
>>
>> tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
>> map definition to be the same as in tc so the ELFs may be interchangeable
>> (at least for now; I don't have a long-term plan in mind to ensure this always
>> works).
>
> Alexei and Daniel, please review.

sorry for delay. swamped at KS+plumbers.
quick note:
I think these patches has to go through Arnaldo's perf tree, since
otherwise they will conflict with Wang's changes.

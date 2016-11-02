From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Wed, 02 Nov 2016 03:46:22 +0100
Message-ID: <5819537E.4080305@iogearbox.net>
References: <20161031183917.9938-1-joe@ovn.org> <66c782de-b2b0-1579-fbb0-634e05e6e511@cumulusnetworks.com> <CAPWQB7HtmX7+v37q9rH_3PD+QfSVg_uRiP_=5ZoKnwsF8gpyKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com, ast@fb.com
To: Joe Stringer <joe@ovn.org>, David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58540 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755249AbcKBCq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 22:46:29 -0400
In-Reply-To: <CAPWQB7HtmX7+v37q9rH_3PD+QfSVg_uRiP_=5ZoKnwsF8gpyKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 11:17 PM, Joe Stringer wrote:
> On 1 November 2016 at 13:51, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 10/31/16 12:39 PM, Joe Stringer wrote:
>>> Update tools/lib/bpf to provide more functionality and improve interoperation
>>> with other tools that generate and use eBPF code.
>>>
>>> The kernel uapi headers are a bit newer than the version in the tools/
>>> directory; synchronize those.
>>>
>>> samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
>>> tools/lib/bpf/bpf* with these functions to bring them into parity.
>>>
>>> tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
>>> map definition to be the same as in tc so the ELFs may be interchangeable
>>> (at least for now; I don't have a long-term plan in mind to ensure this always
>>> works).
>>
>> can samples/bpf be converted to use tools/lib/bpf/libbpf.a?
>
> I have a few other patches sitting around that need this series,
> including an attempt at this.

That sounds great, looking forward!

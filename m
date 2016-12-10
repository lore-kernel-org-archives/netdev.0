From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 net-next 1/8] lib bpf: Add support for BPF_PROG_ATTACH
 and BPF_PROG_DETACH
Date: Sun, 11 Dec 2016 00:18:20 +0100
Message-ID: <584C8D3C.2090901@iogearbox.net>
References: <1481401934-4026-1-git-send-email-dsa@cumulusnetworks.com> <1481401934-4026-2-git-send-email-dsa@cumulusnetworks.com> <584C70C0.8040506@iogearbox.net> <584C71F0.3000203@iogearbox.net> <93dbc1b0-a76e-4375-0a52-6aa5b4a78c7e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43447 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752183AbcLJXSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 18:18:23 -0500
In-Reply-To: <93dbc1b0-a76e-4375-0a52-6aa5b4a78c7e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2016 11:15 PM, David Ahern wrote:
> On 12/10/16 2:21 PM, Daniel Borkmann wrote:
>>>
>>> Please name it bpf_prog_create() then, it would be consistent to
>>> bpf_map_create() and shorter as well.
>>
>> Sorry, lack of coffee, scratch that.
>>
>> Can't the current bpf_prog_attach() stay as is, and you name the above new
>> functions bpf_prog_attach_fd() and bpf_prog_detach_fd()? I think that would
>> be better.
>
> ok. no concerns about consistency with libbpf in the kernel repo?
>
> Seems like making iproute2 and the kernel version the same will allow samples and code to move between them much easier.

I think the lib/bpf.c code is quite different anyway, so I don't think it's
much of a concern or even requirement to look exactly the same as the samples
code (it was also never designed with such requirement). But besides that,
it's also trivial enough from reading the code due to the BPF_PROG_ATTACH
and BPF_PROG_DETACH anyway.

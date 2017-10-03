From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 3/3] tools: bpftool: add documentation
Date: Tue, 03 Oct 2017 18:01:26 +0200
Message-ID: <59D3B456.4020209@iogearbox.net>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com> <20171002231130.12406-4-jakub.kicinski@netronome.com> <20171003005500.yh2gbnofm5ckn54x@ast-mbp> <20171002183509.76b2cc65@cakuba> <20171003042906.24mnbsfbs3bkp2wy@ast-mbp> <881bcc51-015c-097e-a5a4-1f2312a3d9f1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>
To: David Ahern <dsahern@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35421 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdJCQBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 12:01:30 -0400
In-Reply-To: <881bcc51-015c-097e-a5a4-1f2312a3d9f1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 05:39 PM, David Ahern wrote:
> On 10/2/17 9:29 PM, Alexei Starovoitov wrote:
>> On Mon, Oct 02, 2017 at 06:35:09PM -0700, Jakub Kicinski wrote:
>>>> will pretty print them as verifier output as well?
>>>
>>> We tried to use LLVM as a library for this but the interface is
>>> painfully unstable and it's a heavy dependency.  The current thinking
>>> is to try to put the instruction printing code in some higher level
>>> library, but I would rather leave that as a follow up.
>>
>> follow up, of course.
>> Not depending on llvm is must have for this tool.
>> I think we need tiny and simple tools first.
>> Since you're using gpl+bsd license for this tool I think
>> it would be fine to copy-paste verifier's pretty print code into it.
>
> I have done that including integrating it into bpf-tool.

Great, to avoid letting the pretty print code become stale,
could the printer be ripped out of the verifier into its own
file or header under kernel/bpf/ such that it can be used from
kernel but also integrated from bpftool compilation? There's
likely not much kernel specifics in there anyway, wdyt?

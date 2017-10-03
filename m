From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] tools: bpftool: add documentation
Date: Tue, 3 Oct 2017 08:39:36 -0700
Message-ID: <881bcc51-015c-097e-a5a4-1f2312a3d9f1@gmail.com>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
 <20171002231130.12406-4-jakub.kicinski@netronome.com>
 <20171003005500.yh2gbnofm5ckn54x@ast-mbp> <20171002183509.76b2cc65@cakuba>
 <20171003042906.24mnbsfbs3bkp2wy@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36739 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdJCPjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 11:39:43 -0400
Received: by mail-pg0-f67.google.com with SMTP id i195so1762471pgd.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 08:39:42 -0700 (PDT)
In-Reply-To: <20171003042906.24mnbsfbs3bkp2wy@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 9:29 PM, Alexei Starovoitov wrote:
> On Mon, Oct 02, 2017 at 06:35:09PM -0700, Jakub Kicinski wrote:
>>> will pretty print them as verifier output as well?
>>
>> We tried to use LLVM as a library for this but the interface is
>> painfully unstable and it's a heavy dependency.  The current thinking
>> is to try to put the instruction printing code in some higher level
>> library, but I would rather leave that as a follow up.
> 
> follow up, of course.
> Not depending on llvm is must have for this tool.
> I think we need tiny and simple tools first.
> Since you're using gpl+bsd license for this tool I think
> it would be fine to copy-paste verifier's pretty print code into it.
> 

I have done that including integrating it into bpf-tool.

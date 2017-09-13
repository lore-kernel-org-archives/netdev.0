From: Nick Desaulniers <ndesaulniers@google.com>
Subject: Re: [PATCH net] perf/bpf: fix a clang compilation issue
Date: Wed, 13 Sep 2017 10:26:48 -0700
Message-ID: <CAKwvOdmbnU_RcQrpY3p460-50VQf=fTdH_84tFj=WZUZMX_FhQ@mail.gmail.com>
References: <20170908013615.973478-1-yhs@fb.com> <20170911.142857.1205848546110018404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: yhs@fb.com, peterz@infradead.org, rostedt@goodmis.org, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:45631 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751279AbdIMR0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 13:26:51 -0400
Received: by mail-wm0-f48.google.com with SMTP id g206so12374195wme.0
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 10:26:50 -0700 (PDT)
In-Reply-To: <20170911.142857.1205848546110018404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

great, thanks!

On Mon, Sep 11, 2017 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Yonghong Song <yhs@fb.com>
> Date: Thu, 7 Sep 2017 18:36:15 -0700
>
>> clang does not support variable length array for structure member.
>> It has the following error during compilation:
>>
>> kernel/trace/trace_syscalls.c:568:17: error: fields must have a constant size:
>> 'variable length array in structure' extension will never be supported
>>                 unsigned long args[sys_data->nb_args];
>>                               ^
>>
>> The fix is to use a fixed array length instead.
>>
>> Reported-by: Nick Desaulniers <ndesaulniers@google.com>
>> Signed-off-by: Yonghong Song <yhs@fb.com>
>
> Applied.



-- 
Thanks,
~Nick Desaulniers

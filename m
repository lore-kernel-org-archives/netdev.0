From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [patch net] lib: Remove string from parman config selection
Date: Fri, 24 Feb 2017 09:30:56 +0100
Message-ID: <CAMuHMdWFimihnDQ7a4oWX_vz-bo+sgvU7GfX-Q8zHUXV1sr-=g@mail.gmail.com>
References: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
 <CAMuHMdWTm8Z8kuC6oBQFvpq2R289n5zG1wKOxQmMrUdC-OQ-6Q@mail.gmail.com> <20170224082543.GA2357@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32947 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdBXIbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 03:31:39 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so2292807itc.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:30:58 -0800 (PST)
In-Reply-To: <20170224082543.GA2357@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Fri, Feb 24, 2017 at 9:25 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Feb 24, 2017 at 08:54:04AM CET, geert@linux-m68k.org wrote:
>>On Thu, Feb 23, 2017 at 10:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> As reported by Geert, remove the string so the user does not see this
>>> config option. The option is explicitly selected only as a dependency of
>>> in-kernel users.
>>>
>>> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>> Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  lib/Kconfig | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/lib/Kconfig b/lib/Kconfig
>>> index 5d644f1..f355260 100644
>>> --- a/lib/Kconfig
>>> +++ b/lib/Kconfig
>>> @@ -551,6 +551,6 @@ config SBITMAP
>>>         bool
>>>
>>>  config PARMAN
>>> -       tristate "parman"
>>> +       tristate
>>
>>Upon second thought
>>
>>        tristate "parman" if COMPILE_TEST
>>
>>might be better, as it allows to enable and run the accompanying test without
>>dependencies.
>
> Geert, could you please send this as a follow-up? Thanks.

Sure, will do.

Gr{oetje,eeting}s,

                        Geert

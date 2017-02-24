From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] lib: Remove string from parman config selection
Date: Fri, 24 Feb 2017 09:25:43 +0100
Message-ID: <20170224082543.GA2357@nanopsycho>
References: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
 <CAMuHMdWTm8Z8kuC6oBQFvpq2R289n5zG1wKOxQmMrUdC-OQ-6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mlxsw@mellanox.com
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33515 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdBXI6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 03:58:01 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so1905988wmv.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:58:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMuHMdWTm8Z8kuC6oBQFvpq2R289n5zG1wKOxQmMrUdC-OQ-6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 24, 2017 at 08:54:04AM CET, geert@linux-m68k.org wrote:
>Hi Jiri,
>
>On Thu, Feb 23, 2017 at 10:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> As reported by Geert, remove the string so the user does not see this
>> config option. The option is explicitly selected only as a dependency of
>> in-kernel users.
>>
>> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  lib/Kconfig | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/lib/Kconfig b/lib/Kconfig
>> index 5d644f1..f355260 100644
>> --- a/lib/Kconfig
>> +++ b/lib/Kconfig
>> @@ -551,6 +551,6 @@ config SBITMAP
>>         bool
>>
>>  config PARMAN
>> -       tristate "parman"
>> +       tristate
>
>Upon second thought
>
>        tristate "parman" if COMPILE_TEST
>
>might be better, as it allows to enable and run the accompanying test without
>dependencies.
>
>Gr{oetje,eeting}s,
>
>                        Geert


Geert, could you please send this as a follow-up? Thanks.

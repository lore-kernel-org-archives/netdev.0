From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [patch net] lib: Remove string from parman config selection
Date: Fri, 24 Feb 2017 08:54:04 +0100
Message-ID: <CAMuHMdWTm8Z8kuC6oBQFvpq2R289n5zG1wKOxQmMrUdC-OQ-6Q@mail.gmail.com>
References: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34955 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdBXHyL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 02:54:11 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so2144377ith.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 23:54:10 -0800 (PST)
In-Reply-To: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Thu, Feb 23, 2017 at 10:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> As reported by Geert, remove the string so the user does not see this
> config option. The option is explicitly selected only as a dependency of
> in-kernel users.
>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  lib/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/lib/Kconfig b/lib/Kconfig
> index 5d644f1..f355260 100644
> --- a/lib/Kconfig
> +++ b/lib/Kconfig
> @@ -551,6 +551,6 @@ config SBITMAP
>         bool
>
>  config PARMAN
> -       tristate "parman"
> +       tristate

Upon second thought

        tristate "parman" if COMPILE_TEST

might be better, as it allows to enable and run the accompanying test without
dependencies.

Gr{oetje,eeting}s,

                        Geert

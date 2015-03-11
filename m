From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next] dsa: change "select" to "depends on" for
 switchdev in Kconfig
Date: Wed, 11 Mar 2015 09:46:21 -0700
Message-ID: <CAGVrzcY9bU+qdYtKj7RBkT0FhhbEUv9oxcTtrYSzqp5PFJWteQ@mail.gmail.com>
References: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:41442 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbbCKQrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:47:02 -0400
Received: by igal13 with SMTP id l13so13884826iga.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:47:02 -0700 (PDT)
In-Reply-To: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-11 9:44 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
>
> Also it fixes following warning:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
>
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/Kconfig | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index b45206e..9379a9c 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -6,9 +6,8 @@ config HAVE_NET_DSA
>
>  config NET_DSA
>         tristate
> -       depends on HAVE_NET_DSA
> +       depends on HAVE_NET_DSA && NET_SWITCHDEV
>         select PHYLIB
> -       select NET_SWITCHDEV
>
>  if NET_DSA
>
> --
> 1.9.3
>



-- 
Florian

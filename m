From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 15:53:28 +0900
Message-ID: <CAK7LNAQ3UCFXOsCU6t_RJfe4Suxz3BmJGaBw7fMTy=z8JoJ2Bw@mail.gmail.com>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-20 8:42 GMT+09:00 Nicolas Pitre <nicolas.pitre@linaro.org>:
> diff --git a/Documentation/kbuild/kconfig-language.txt b/Documentation/kbuild/kconfig-language.txt
> index 069fcb3eef..c96127f648 100644
> --- a/Documentation/kbuild/kconfig-language.txt
> +++ b/Documentation/kbuild/kconfig-language.txt
> @@ -113,6 +113,33 @@ applicable everywhere (see syntax).
>         That will limit the usefulness but on the other hand avoid
>         the illegal configurations all over.
>
> +- weak reverse dependencies: "imply" <symbol> ["if" <expr>]
> +  This is similar to "select" as it enforces a lower limit on another
> +  symbol except that the "implied" config symbol's value may still be
> +  set to n from a direct dependency or with a visible prompt.
> +  Given the following example:
> +
> +  config FOO
> +       tristate
> +       imply BAZ
> +
> +  config BAZ
> +       tristate
> +       depends on BAr


s/BAr/BAR/  ?





-- 
Best Regards
Masahiro Yamada

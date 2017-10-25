From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [iproute PATCH] ss: add detail explains of -m, -o, -e and -i options in ss man page
Date: Wed, 25 Oct 2017 11:06:08 -0400
Message-ID: <8560b3clnj.fsf@mojatatu.com>
References: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, phil@nwl.cc
To: peng yu <yupeng0921@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:54236 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751637AbdJYPGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 11:06:11 -0400
Received: by mail-io0-f194.google.com with SMTP id 189so1311312iow.10
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 08:06:11 -0700 (PDT)
In-Reply-To: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
        (peng yu's message of "Tue, 24 Oct 2017 17:13:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

peng yu <yupeng0921@gmail.com> writes:

> commit 340a45f79395144bd14fdf9be1904c0036456b6e
> Author: yupeng <yupeng0921@gmail.com>
> Date:   Tue Oct 24 23:55:29 2017 +0000
>
>     add additional explain in ss man page
>
>     Add detail explains of -m, -o, -e and -i options, which are not
> documented anywhere
>
>     Signed-off-by: Peng Yu <yupeng0921@gmail.com>
>
> diff --git a/man/man8/ss.8 b/man/man8/ss.8
> index 3bec97f..4597733 100644
> --- a/man/man8/ss.8
> +++ b/man/man8/ss.8
> @@ -176,6 +176,147 @@ states except for
>  - opposite to
>  .B bucket
>
> +.SH Additional explain of -m, -o, -e and -i options
> +Some fields may have different meanings if the netowrk protocl is
> different. Below explain focus on tcp protocol.
> +.TP
> +.B -m option
> +skmem:(r<rmem_alloc>,rb<rcv_buf>,t<wmem_alloc>,tb<snd_buf>,f<fwd_alloc>,w<wmem_queued>,o<opt_mem>,bl<back_log>)
> +
> +.B <rmem_alloc>
> +the memory allocated for receiving package
> +

Need to change 'package' to 'packet' in multiple places.

[...]

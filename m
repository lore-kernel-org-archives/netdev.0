From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint trace_tcp_retransmit_synack()
Date: Thu, 26 Oct 2017 19:01:26 -0700
Message-ID: <CAM_iQpVzGpype9ytprzF9zcigZ6ckE03SYnGPdfSxUQRgqV82Q@mail.gmail.com>
References: <201710261134.MUf5E7cp%fengguang.wu@intel.com> <2552809E-4EBC-4F3D-94A4-41BE0ECB27C2@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild test robot <lkp@intel.com>,
        David Miller <davem@davemloft.net>,
        "kbuild-all@01.org" <kbuild-all@01.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        Martin Lau <kafai@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>
To: Song Liu <songliubraving@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:50945 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdJ0CBr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 22:01:47 -0400
Received: by mail-pg0-f52.google.com with SMTP id y5so4115986pgq.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 19:01:47 -0700 (PDT)
In-Reply-To: <2552809E-4EBC-4F3D-94A4-41BE0ECB27C2@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 4:50 PM, Song Liu <songliubraving@fb.com> wrote:
> In this case, we are putting CONFIG_IPV6 in TRACE_EVENT macro, which generates
> warnings like:
>
> ./include/trace/events/tcp.h:274:1: error: directive in argument list
> ./include/trace/events/tcp.h:281:1: error: directive in argument list
>
> Seems these warning cannot be easily avoided. This is also the same pattern we
> have been using in include/trace/events/tcp.h.

Hmm, we use the same so why it only complains about this one?

>
> Any suggestions on how shall we proceed from here?
>

I think this warning is harmless, so perhaps not worthy time to
shut it up, unless sparse provides a simple way to do so.

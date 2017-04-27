From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Thu, 27 Apr 2017 07:49:29 -0700
Message-ID: <CAADnVQ+GL6sYCff4eU4WXZYeZSi5BJ5amy6NQjuZk2=OjuM5+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Jiri Benc <jbenc@redhat.com>,
        Aaron Conole <aconole@bytheb.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38463 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939440AbdD0Ot4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 10:49:56 -0400
Received: by mail-wm0-f46.google.com with SMTP id r190so21005081wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 07:49:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 6:17 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> cap_sys_admin influences the verifier a lot in terms which programs are
> accepted and which are not. So during investigations it might be even
> interesting if the bpf program required those special flags or if the
> same program could be loaded just as underprivileged.

there are bunch of other things that influence verifier.
should we add all of them ?
there is prog->aux->user which is more than enough for
debugging.

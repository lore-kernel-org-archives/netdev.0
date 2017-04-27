From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 07:45:54 -0700
Message-ID: <CAADnVQ+pHVZaUGBWXZSRUgzAkGhnfjhPOF0zTaOqpH4PpAiXCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.com,
        Jiri Benc <jbenc@redhat.com>,
        Aaron Conole <aconole@bytheb.org>,
        Martin KaFai Lau <kafai@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36714 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938580AbdD0OqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 10:46:16 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so5044160wmu.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 07:46:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 6:28 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
>> I don't want this to become debugfs for bpf.
>
> Right now it just prints a list of ebpf programs. You reject of where
> things are going or do you already reject this particular patch?

both.
procfs/debugfs always starts as 'i just print a little, because it's easier'
and the next thing you know it's full of knobs and user tooling
to parse this text.

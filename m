From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ping: What's the purpose of rate limit?
Date: Tue, 3 Jan 2017 22:45:17 -0800
Message-ID: <CAM_iQpWBs1eUwfLprSsEFAtpMUWPY-jgXswzoHGck0DxxPQdZQ@mail.gmail.com>
References: <CANeMGR4=vycxBU+LcrL2JXHt2FTYBkU2aLxfY5XRzHdws-aYag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guan Xin <guanx.bac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:33478 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965822AbdADGpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 01:45:38 -0500
Received: by mail-qt0-f170.google.com with SMTP id v23so14663280qtb.0
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 22:45:38 -0800 (PST)
In-Reply-To: <CANeMGR4=vycxBU+LcrL2JXHt2FTYBkU2aLxfY5XRzHdws-aYag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Dec 31, 2016 at 4:04 AM, Guan Xin <guanx.bac@gmail.com> wrote:
> Hello,
>
> Excuse me, I searched but didn't find an answer --
>
> What's the purpose of setting a limit to the "-i" and "-l" parameters
> of ping for non-root users?
>
> It seems that this is only intended to prevent accidental misuse
> because these restrictions can be easily worked around by starting
> multiple instances or wrapping the program in a loop, e.g.,
> while true; do ping -l3 -c3 192.168.0.1; done
>

I think the purpose of "-i" is not for rate limit, but for either hear beating
or monitoring latency periodically.

Thanks.

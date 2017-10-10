From: Kees Cook <keescook@chromium.org>
Subject: Re: net/wireless/ray_cs: Convert timers to use
Date: Tue, 10 Oct 2017 07:22:05 -0700
Message-ID: <CAGXu5j+S0Nm-gqeKfD2oPNanXoWUZ4NSraPab4MoJrdxFP6p3g@mail.gmail.com>
References: <20171005005020.GA23219@beast> <20171010082603.8E283607C5@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:46153 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755919AbdJJOWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:22:07 -0400
Received: by mail-io0-f178.google.com with SMTP id 101so11778530ioj.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:22:07 -0700 (PDT)
In-Reply-To: <20171010082603.8E283607C5@smtp.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 1:26 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Kees Cook <keescook@chromium.org> wrote:
>
>> In preparation for unconditionally passing the struct timer_list pointer to
>> all timer callbacks, switch to using the new timer_setup() and from_timer()
>> to pass the timer pointer explicitly.
>>
>> Cc: Kalle Valo <kvalo@codeaurora.org>
>> Cc: linux-wireless@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> I'll apply this once I have fast forwarded wireless-drivers-next to
> -rc3. I'll also fix the title, what was it supposed to say?

It was truncated from "net/wireless/ray_cs: Convert timers to use
timer_setup()"; I've fixed that glitch in my workflow now.

> Patch set to Awaiting Upstream.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

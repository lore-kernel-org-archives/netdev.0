From: Kees Cook <keescook@chromium.org>
Subject: Re: drivers/wireless: ath: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 11:29:08 +0200
Message-ID: <CAGXu5jLY0nUOXThRUa_q7h2JRSBp_YSFQGF19+EhZ4Q_kFLqQg@mail.gmail.com>
References: <20171024092954.GA47365@beast> <df4525f9d784450fabe4bf685af6992e@euamsexm01a.eu.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:54239 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdJ0J3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 05:29:10 -0400
Received: by mail-io0-f194.google.com with SMTP id 189so11385790iow.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 02:29:10 -0700 (PDT)
In-Reply-To: <df4525f9d784450fabe4bf685af6992e@euamsexm01a.eu.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 11:18 AM, Kalle Valo <kvalo@qca.qualcomm.com> wrote:
> Kees Cook <keescook@chromium.org> wrote:
>
>> In preparation for unconditionally passing the struct timer_list pointer to
>> all timer callbacks, switch to using the new timer_setup() and from_timer()
>> to pass the timer pointer explicitly.
>>
>> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
>> Cc: linux-wireless@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
>
> There were some conflicts but luckily 3-way merge was able to automatically
> solve them. But please do check the patch from my pending branch:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git/commit/?h=master-pending&id=dd08329d31a4c150f8aab8274033901baaf3e923

This looks correct to me, thanks for merging!

-Kees

-- 
Kees Cook
Pixel Security

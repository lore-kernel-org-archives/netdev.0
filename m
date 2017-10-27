From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: qtnfmac: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:43:45 +0000 (UTC)
Message-ID: <20171027074345.AD4A16044E@smtp.codeaurora.org>
References: <20171024092837.GA47040@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55140 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752058AbdJ0Hnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:43:46 -0400
In-Reply-To: <20171024092837.GA47040@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Igor Mitsyanko <imitsyanko@quantenna.com>
> Cc: Avinash Patil <avinashp@quantenna.com>
> Cc: Sergey Matyukevich <smatyukevich@quantenna.com>
> Cc: Kamlesh Rath <krath@quantenna.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

7e916cafb4d9 qtnfmac: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023851/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: cw1200: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:46:48 +0000 (UTC)
Message-ID: <20171027074648.8060A605A8@smtp.codeaurora.org>
References: <20171024092900.GA47129@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56902 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdJ0Hqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:46:49 -0400
In-Reply-To: <20171024092900.GA47129@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Solomon Peachy <pizza@shaftnet.org>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

e3dcf8bbeb0c cw1200: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023845/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

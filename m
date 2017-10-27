From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:49:16 +0000 (UTC)
Message-ID: <20171027074916.B582E601DA@smtp.codeaurora.org>
References: <20171024092928.GA47234@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Ingo Molnar <mingo@kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Zaborowski <andrew.zaborowski@intel.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33186 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdJ0HtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:49:17 -0400
In-Reply-To: <20171024092928.GA47234@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Johannes Berg <johannes.berg@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Andrew Zaborowski <andrew.zaborowski@intel.com>
> Cc: libertas-dev@lists.infradead.org
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

78ce6a9083c4 libertas: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023823/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

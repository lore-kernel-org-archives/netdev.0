From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:48:32 +0000 (UTC)
Message-ID: <20171027074832.9CD3360314@smtp.codeaurora.org>
References: <20171024092919.GA47203@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Ingo Molnar <mingo@kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Zaborowski <andrew.zaborowski@intel.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59810 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdJ0Hsd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:48:33 -0400
In-Reply-To: <20171024092919.GA47203@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Amitkumar Karwar <amitkarwar@gmail.com>
> Cc: Nishant Sarmukadam <nishants@marvell.com>
> Cc: Ganapathi Bhat <gbhat@marvell.com>
> Cc: Xinming Hu <huxm@marvell.com>
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

08c2eb8ec800 mwifiex: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023837/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

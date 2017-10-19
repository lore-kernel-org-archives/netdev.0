From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] wireless: iwlegacy: Convert timers to use timer_setup()
Date: Thu, 19 Oct 2017 10:54:15 +0200
Message-ID: <20171019085414.GB22113@redhat.com>
References: <20171016233744.GA101655@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171016233744.GA101655@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 04:37:44PM -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 00/58] networking: Convert timers to use timer_setup()
Date: Tue, 17 Oct 2017 17:18:29 +0300
Message-ID: <87mv4pvowa.fsf@purkki.adurom.net>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org> (Kees
        Cook's message of "Mon, 16 Oct 2017 17:28:44 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ linux-wireless

Hi Kees,

Kees Cook <keescook@chromium.org> writes:

> This is the current set of outstanding networking patches to perform
> conversions to the new timer interface (rebased to -next). This is not
> all expected conversions, but it contains everything needed in networking
> to eliminate init_timer(), and all the non-standard setup_*_timer() uses.

So this also includes patches which I had queued for
wireless-drivers-next:

https://patchwork.kernel.org/patch/9986253/
https://patchwork.kernel.org/patch/9986245/

And looking at patchwork[1] I have even more timer_setup() related
patches from you. It would be really helpful if you could clearly
document to which tree you want the patches to be applied. I don't care
if it's net-next or wireless-drivers-next as long as it's not the both
(meaning that both Dave and me apply the same patch, which would be
bad). The thing is that I really do not have time to figure out for
every patch via which tree it's supposed to go.

For now I'll just drop all your timer_setup() related patches from my
queue and I'll assume Dave will take those. Ok?

[1] https://patchwork.kernel.org/project/linux-wireless/list/

-- 
Kalle Valo

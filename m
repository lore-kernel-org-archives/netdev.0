From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/58] networking: Convert timers to use timer_setup()
Date: Wed, 18 Oct 2017 12:42:19 +0100 (WEST)
Message-ID: <20171018.124219.174286495547300072.davem@davemloft.net>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Mon, 16 Oct 2017 17:28:44 -0700

> This is the current set of outstanding networking patches to perform
> conversions to the new timer interface (rebased to -next). This is not
> all expected conversions, but it contains everything needed in networking
> to eliminate init_timer(), and all the non-standard setup_*_timer() uses.

I've applied this except:

1) the IRDA stuff, it's staging and needs to go via Greg KH

2) the MPC ATM didn't apply at all to net-next

Such a huge patch series like this is a huge burdon upon
a subsystem maintainer.

Split this kind of stuff up into manageable chunks next time,
maybe a dozen patches at a time.  Do not submit multiple
series at once to get around this size limit.  Submit one
at a time, wait for it to get applied, and then after that
you can submit the next one.

Thanks.

From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 00/58] networking: Convert timers to use timer_setup()
Date: Wed, 18 Oct 2017 12:42:16 -0700
Message-ID: <CAGXu5jK7PhuYD5Zr7dOBax3VPsvKzFSpv2b4_mNRP-AiUJ0Kcg@mail.gmail.com>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org> <20171018.124219.174286495547300072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018.124219.174286495547300072.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 4:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Mon, 16 Oct 2017 17:28:44 -0700
>
>> This is the current set of outstanding networking patches to perform
>> conversions to the new timer interface (rebased to -next). This is not
>> all expected conversions, but it contains everything needed in networking
>> to eliminate init_timer(), and all the non-standard setup_*_timer() uses.
>
> I've applied this except:
>
> 1) the IRDA stuff, it's staging and needs to go via Greg KH

Ah yes, thanks. I didn't update the Subject when I followed the path
change into staging. I'll redirect this to Greg.

> 2) the MPC ATM didn't apply at all to net-next

Okay, I will respin it again and collect more conversions before
sending the next batch.

> Such a huge patch series like this is a huge burdon upon
> a subsystem maintainer.

Agreed, and I'm very thankful you've made time to dig through this
pile. I've tried to minimize the number of separate patches, since
many cases can be mechanically updated with Coccinelle (which we'll do
at the tail end of this conversion).

> Split this kind of stuff up into manageable chunks next time,
> maybe a dozen patches at a time.  Do not submit multiple
> series at once to get around this size limit.  Submit one
> at a time, wait for it to get applied, and then after that
> you can submit the next one.

Okay, I'll limit postings to a dozen. I think I'll need to maintain
separate trees for each subsystem's batches. I've been splitting them
up manually out of one single giant tree, which has been ... insane.

Thanks again!

-Kees

-- 
Kees Cook
Pixel Security

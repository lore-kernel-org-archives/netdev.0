From: Kees Cook <keescook@chromium.org>
Subject: Re: Timer breakage in net-next
Date: Fri, 27 Oct 2017 11:09:15 +0200
Message-ID: <CAGXu5jKxV9D+4fJhrnB=gnkeQP_G11L_qnpiC8vF5AS=VtFOSg@mail.gmail.com>
References: <22485.1509091558@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22485.1509091558@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 10:05 AM, David Howells <dhowells@redhat.com> wrote:
> Hi Dave, Kees,
>
> Is it possible to get this timer fix:
>
>         https://patchwork.ozlabs.org/patch/828333/
>
>         timer: Provide wrappers safe for use with LOCKDEP
>
> included in net-next?

FWIW, the LOCKDEP warnings are false positives. The fix includes
updates to one new API function, which would be an additional patch.
When I talked with Thomas, it sounded like it was better just to wait
for the merge window instead of trying to figure out a way to land
this separately in other trees. Obviously this is up to Dave, but it
seemed like a merge of tip/timers/core into net-next would be
confusing.

> You can add my Tested-by line.

Thanks for checking it!

-Kees

-- 
Kees Cook
Pixel Security

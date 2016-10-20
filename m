From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 0/4] make POSIX timers optional with some Kconfig help
Date: Thu, 20 Oct 2016 11:51:22 -0700
Message-ID: <20161020185122.ymwvqiqslf32eife@x>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 07:42:49PM -0400, Nicolas Pitre wrote:
> Many embedded systems don't need the full POSIX timer support.
> Configuring them out provides a nice kernel image size reduction.
> 
> When POSIX timers are configured out, the PTP clock subsystem should be
> left out as well. However a bunch of ethernet drivers currently *select*
> the later in their Kconfig entries. Therefore some more work was needed
> to break that hard dependency from those drivers without preventing their
> usage altogether.
> 
> Therefore this series also includes kconfig changes to implement a new
> keyword to express some reverse dependencies like "select" does, named
> "imply", and still allowing for the target config symbol to be disabled
> if the user or a direct dependency says so.
> 
> How to deal with the dependencies across three subsystems for potential
> upstream merging needs to be figured out.

This looks good to me, and I like the new "imply" approach.

I'd still like to see a more general solution for reporting the use of
compiled-out syscalls, but I don't think that needs to block this patch
series.

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

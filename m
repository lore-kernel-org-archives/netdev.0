From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 0/5] make POSIX timers optional with some Kconfig help
Date: Sat, 29 Oct 2016 00:50:45 +0200
Message-ID: <1477695045.2167.48.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-10-25 at 22:28 -0400, Nicolas Pitre wrote:
> When POSIX timers are configured out, the PTP clock subsystem should be
> left out as well. However a bunch of ethernet drivers currently *select*
> the later in their Kconfig entries. Therefore some more work was needed
> to break that hard dependency from those drivers without preventing their
> usage altogether.

By the way: would you have pointers to threads that discussed attempts
to achieve this using currently available Kconfig options?

Thanks,


Paul Bolle

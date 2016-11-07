From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v3 0/4] make POSIX timers optional with some Kconfig
 help
Date: Mon, 7 Nov 2016 17:31:50 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1611071723280.14694@knanqh.ubzr>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 Nov 2016, Nicolas Pitre wrote:

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
> At this point I'd like to gather ACKs especially from people in the "To"
> field. Ideally this would need to go upstream as a single series to avoid
> cross subsystem dependency issues.  So far it was suggested that this should go
> via the kbuild tree.

This is also available here for those who prefer a git tree:

git://git.linaro.org/people/nicolas.pitre/linux/ configurable_posix_timers


Nicolas

From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 0/4] make POSIX timers optional with some Kconfig
 help
Date: Tue, 8 Nov 2016 17:47:53 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1611081747330.3501@nanos>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:55474 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932301AbcKHQug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:50:36 -0500
In-Reply-To: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

For the whole series:

Acked-by: Thomas Gleixner <tglx@linutronix.de>

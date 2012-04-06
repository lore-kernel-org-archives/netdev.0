From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent
 execve from granting privs
Date: Fri, 6 Apr 2012 12:49:21 -0700
Message-ID: <20120406124921.5754e941.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-2-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org, Andy Lutomirski <luto@amacapital.net>
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1333051320-30872-2-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:46 -0500
Will Drewry <wad@chromium.org> wrote:

> From: Andy Lutomirski <luto@amacapital.net>
> 
> With this set, a lot of dangerous operations (chroot, unshare, etc)
> become a lot less dangerous because there is no possibility of
> subverting privileged binaries.
> 
> This patch completely breaks apparmor.  Someone who understands (and
> uses) apparmor should fix it or at least give me a hint.

So [patch 2/15] fixes all this up?

I guess we should join the two patches into one, to avoid a silly
breakage window.  That means that John loses a brownie point, but we
can mention him in the changelog, include his signed-off-by:

> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Several of these patches are missing your signed-off-by:.  They should
all have your SOB, because you sent them. 
Documentation/SubmittingPatches explains this.

I'm trying to find a way to merge all this code without reviewing it ;)
Alas, this is against my rules.  Given the length of time for which
this patchset has been floating around, I'm a little surprised by the
lack of acked-by's and reviewed-by's.  Have you been gathering them all
up?  Are the networking guys all happy about this patchset?

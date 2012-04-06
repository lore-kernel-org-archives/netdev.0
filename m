From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 6 Apr 2012 13:01:17 -0700
Message-ID: <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406125517.77133b4e.akpm@linux-foundation.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>, linux-man@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <kernel-hardening-return-1198-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: amluto@gmail.com
In-Reply-To: <20120406125517.77133b4e.akpm@linux-foundation.org>
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 12:55 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 29 Mar 2012 15:01:46 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> From: Andy Lutomirski <luto@amacapital.net>
>>
>> With this set, a lot of dangerous operations (chroot, unshare, etc)
>> become a lot less dangerous because there is no possibility of
>> subverting privileged binaries.
>
> The changelog doesn't explain the semantics of the new syscall.
> There's a comment way-down-there which I guess suffices, if you hunt
> for it.
>
> And the changelog doesn't explain why this is being added. =A0Presumably
> seccomp_filter wants/needs this feature but whowhatwherewhenwhy? =A0Spell
> it all out, please.
>
> The new syscall mode will be documented in the prctl manpage. =A0Please
> cc linux-man@vger.kernel.org and work with Michael on getting this
> done?

This has been bugging me for awhile.  Is there any interest in moving
the manpages into the kernel source tree?  Then there could be a
general requirement that new APIs get documented when they're written.

(There are plenty of barely- or incompletely-documented syscalls.
futex and relatives come to mind.)

--Andy

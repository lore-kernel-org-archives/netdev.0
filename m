From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent
 execve from granting privs
Date: Fri, 6 Apr 2012 12:55:17 -0700
Message-ID: <20120406125517.77133b4e.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-2-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org,
	mcgrathr-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, luto-3s7WtUTddSA@public.gmane.org,
	eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, djm-ilwOsaqNJrtAfugRpC6u6w@public.gmane.org,
	scarybeasts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indan-1J6HnF7K7zE@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	corbet-T1hC0tSOHrs@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, markus-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	coreyb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1333051320-30872-2-git-send-email-wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:46 -0500
Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:

> From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> 
> With this set, a lot of dangerous operations (chroot, unshare, etc)
> become a lot less dangerous because there is no possibility of
> subverting privileged binaries.

The changelog doesn't explain the semantics of the new syscall. 
There's a comment way-down-there which I guess suffices, if you hunt
for it.

And the changelog doesn't explain why this is being added.  Presumably
seccomp_filter wants/needs this feature but whowhatwherewhenwhy?  Spell
it all out, please.

The new syscall mode will be documented in the prctl manpage.  Please
cc linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org and work with Michael on getting this
done?

>
> ...
>
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom load_pointer
Date: Thu, 1 Mar 2012 16:22:37 -0800
Message-ID: <CAObL_7E098p_kauJEszzm9GZAyr5aSxZfNQovq2NhP5yTHMAGA@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org> <20120301233712.GS3990@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120301233712.GS3990@outflux.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 1, 2012 at 3:37 PM, Kees Cook <keescook@chromium.org> wrote:
> Hi,
>
> So far, it looks like everyone who spoke up is satisfied with this patch
> series. Or their MUAs got caught up on a leap-year bug and missed the
> posting. ;)
>
> Is it time to pull this into -next so more people can feel it? I brought
> Andy Lutomirski's patches forward (needed to bump the prctl values), and
> updated my git tree. If we're ready, here it is in all its request-pull
> format glory:
>
> [...]

Should we set up a site with associated example userspace tools?  For
example, this:

http://web.mit.edu/luto/www/linux/nnp/

(although newns.c isn't as useful without the rest of my patches, but
that's a separate discussion.)

At least pam_nnp.c is useful, and when this stuff hits mainline, I'll
try to push it to linux-pam.  Presumably you and Will have similar
little hacks to play with.

--Andy

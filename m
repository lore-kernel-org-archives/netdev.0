From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom load_pointer
Date: Thu, 1 Mar 2012 21:41:51 -0600
Message-ID: <CABmXcB83uFMUFUuRKCtkMjU2KLv7N4JB08qzZLVDdT=CStmQjw@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
	<20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
	<CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
	<20120302141038.aaafc42b59ac7cf95d3553ed@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kees Cook <keescook@chromium.org>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120302141038.aaafc42b59ac7cf95d3553ed@canb.auug.org.au>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 1, 2012 at 9:10 PM, Stephen Rothwell <sfr@canb.auug.org.au>=
 wrote:
> Hi Kees,
>
> On Thu, 1 Mar 2012 16:57:49 -0800 Kees Cook <keescook@chromium.org> w=
rote:
>>
>> Unfortunately, yes, it does -- there were both ptrace changes and pr=
ctl changes.
>>
>> And at least the ptrace changes are, IIRC, in -mm, which has no tree=
=2E
>> :P Given that, what's the best thing for me to do for this to be eas=
y
>> for you to pull?
>
> Does this set of patches *depend* on functionality provided by those,=
 or
> just produce conflicts against the other changes? =A0If it is just
> conflicts, then base your tree on Linus and I and (he when it comes t=
o
> it) can fix the conflicts as needed (with some hints if you think it =
is a
> good idea i.e. is the conflicts are particularly complex).

No explicit dependency.   It's just a conflict in how ptrace options
are set, defined, and masked (and STOP being renumbered).  Other than
the ptrace changes, the whole series patches cleanly onto both trees.
The resolved version is less code and easier to read, so I don't
suspect it'll be a challenge at all.

thanks!

From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Thu, 12 Apr 2012 07:31:16 +1200
Message-ID: <CAKgNAkhhnC1+vdh7vTYKkngzxHccDwHH_aKF5wCNhga33BGhyQ@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406125517.77133b4e.akpm@linux-foundation.org>
 <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com> <20120406142824.61d8ca3b@lwn.net>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lutomirski <luto@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>,
	linux-man@vger.kernel.org
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120406142824.61d8ca3b@lwn.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 7, 2012 at 8:28 AM, Jonathan Corbet <corbet@lwn.net> wrote:
> On Fri, 6 Apr 2012 13:01:17 -0700
> Andrew Lutomirski <luto@mit.edu> wrote:
>
>> This has been bugging me for awhile. =A0Is there any interest in mov=
ing
>> the manpages into the kernel source tree? =A0Then there could be a
>> general requirement that new APIs get documented when they're writte=
n.
>
> Man page (or other documentation) requirements for patch acceptance a=
re a
> regular kernel summit feature. =A0People seem to think it's a good id=
ea, but
> actual enforcement of such requirements always seems to be lacking. =A0=
Lots
> of people have kind of given up trying. =A0I don't really see that ad=
ding
> the man pages to the tree would help, but I could be wrong...

I largely consider this (moving man pages to kernel.org) a technical
solution to what is fundamentally a social problem (developers
reluctant to write documentation), and doubt that the technical
solution would make much difference. I'd love to be proved wrong, but
the experiment would require significant start-up effort. (My
collected thoughts on this can be found here:
http://www.kernel.org/doc/man-pages/todo.html#migrate_to_kernel_source.
Note the alternative idea of patch tags mentioned at the end of that
text.)

Unless, or until there's a paid maintainer, I don't expect things to
get significantly better than what they currently are. The quite
significant improvements in man-pages since 2004, when I became
maintainer were in small part due to the fact that I was for a short
period paid to do the work, but in much larger part due to a huge
private effort over those years which over the last couple of years is
no longer unsustainable for me (man-pages is in competition with
requirements for my attention from family, working life, and
(seriously!) seismic events),

Cheers,

Michael


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

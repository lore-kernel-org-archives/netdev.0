From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 6 Apr 2012 13:37:46 -0700
Message-ID: <CAObL_7GGS-veaVUhEphhO69Rh08eT3683W9LJx2f9twLi2RW7A@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406125517.77133b4e.akpm@linux-foundation.org>
 <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com> <20120406142824.61d8ca3b@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
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

On Fri, Apr 6, 2012 at 1:28 PM, Jonathan Corbet <corbet@lwn.net> wrote:
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
>

If it's in the source, then I can send it with git format-patch.  If
it's out of tree, I have to find the tree, clone the tree, figure out
how to submit, and send separate emails.  And then whoever checks that
I documented it has to figure out where I sent it and how to read it
and then try to decide which documentation submission matches which
patch submission.

(Also, if it's in-tree, then I can build the docs from a kernel tree
and have the latest ones.  That could be nice.)

--Andy

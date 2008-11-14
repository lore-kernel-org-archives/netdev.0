From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] reintroduce accept4
Date: Fri, 14 Nov 2008 10:24:22 -0500
Message-ID: <517f3f820811140724l49dd0f31xffda837afd1986a8@mail.gmail.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	 <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	 <20081113140541.23754cad.akpm@linux-foundation.org>
	 <18716.43376.534965.688695@cargo.ozlabs.ibm.com>
	 <18716.43543.256621.825529@cargo.ozlabs.ibm.com>
	 <20081113145737.96898aaf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Paul Mackerras" <paulus@samba.org>, subrata@linux.vnet.ibm.com,
	linux-arch@vger.kernel.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-api@vger.kernel.org, linux-man@vger.kernel.org,
	davidel@xmailserver.org, netdev@vger.kernel.org, roland@redhat.com,
	oleg@tv-sign.ru, hch@lst.de, davem@davemloft.net, alan@redhat.com,
	jakub@redhat.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20081113145737.96898aaf.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew,

> From: Ulrich Drepper <drepper@redhat.com>
>
> Introduce a new accept4() system call.  The addition of this system call
> matches analogous changes in 2.6.27 (dup3(), evenfd2(), signalfd4(),
> inotify_init1(), epoll_create1(), pipe2()) which added new system calls
> that differed from analogous traditional system calls in adding a flags
> argument that can be used to access additional functionality.
>
> The accept4() system call is exactly the same as accept(), except that it
> adds a flags bit-mask argument.  Two flags are initially implemented.
> (Most of the new system calls in 2.6.27 also had both of these flags.)

Add a para break here.

> SOCK_CLOEXEC causes the close-on-exec (FD_CLOEXEC) flag to be enabled for
> the new file descriptor returned by accept4().  This is a useful security
> feature to avoid leaking information in a multithreaded program where one
> thread is doing an accept() at the same time as another thread is doing a
> fork() plus exec().
>

This para break is in the wrong place.

> More details here: http://udrepper.livejournal.com/20407.html "Secure File
> Descriptor Handling", Ulrich Drepper) The other flag is SOCK_NONBLOCK,

The para break should actually be at the sentence break in the previous line.

Cheers,

Michael

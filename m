From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 13:27:23 +0100
Message-ID: <20090916122723.GE29359@shareable.org>
References: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <20090916120523.GA12830@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090916120523.GA12830@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> It all sounds good and simple, but what if you will need modify command
> with new arguments? Instead of adding new typed option you will need to
> add another syscall. I already did that for inotify but via ioctl and
> pretty sure there will be such need for much wider fanotify some time in
> the future.

Ew, that's unpleasant (adding to inotify via ioctl).

You're right, it's not easy to add new syscalls, but it's not that
hard either.

I'd forgotten about Linus' strace argument.  That's a good one.

Of course everything should be a syscall by that argument :-)

And strace can trace some ioctls and setsockopts.  (But it's never
pretty to see isatty() showing in strace as SNDCTL_TMR_TIMEBASE :-)

Strace never shows structure of reads and writes to devices, so
although efficient (you can batch), it's not nice for tracing.

-- Jamie

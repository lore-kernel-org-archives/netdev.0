From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 17:27:07 +0100
Message-ID: <20090922162707.GA11608@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <20090921231227.GJ14700@shareable.org> <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com> <200909221731.34717.agruen@suse.de> <1253635918.2747.5.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Davide Libenzi <davidel@xmailserver.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756962AbZIVQ1a@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1253635918.2747.5.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris wrote:
> That's not the fatal flaw.  The fatal flaw is that I am not going to
> write 90% of a rootkit and make it easy to use.

I hate to point out the obvious, but fanotify's ability to intercept
every file access and rewrite the file before the access proceeds is
also 90% of a rootkit...

But fortunately both fanotify and syscall rewriting require root in
the first place.

I think that makes the rootkit argument moot.  As long as fanotify
doesn't have a non-root flavour... which really would be handy for
rootkits :-)

> Easy != Good.

I agree.

-- Jamie

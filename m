From: "David S. Miller" <davem@redhat.com>
Subject: Re: [APPLETALK]: Use '%Z' for size_t.
Date: Thu, 19 Feb 2004 10:09:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219100914.1a17e797.davem@redhat.com>
References: <200402190209.i1J29KF2020707@hera.kernel.org>
	<1077204436.18703.412.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1077204436.18703.412.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 15:27:17 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Wed, 2004-02-18 at 21:11 +0000, Linux Kernel Mailing List wrote:
> > ChangeSet 1.1561.2.2, 2004/02/18 13:11:42-08:00, davem@nuts.davemloft.net
> > 
> > 	[APPLETALK]: Use '%Z' for size_t.
> 
> %Zd is an ancient GNUism. Please use %zd in new code instead.

As long as lib/vsprintf.c in the kernel supports it, there is no reason not
to use it.  They're never going to remove recognition of this thing from
gcc printf's parsing.

If it really bothers you, then go sick a kernel janitor onto it, because there
are thousands of uses of %Z, I know because I put most of them into the tree :-)

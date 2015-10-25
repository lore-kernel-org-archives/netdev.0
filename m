From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Linux 4.2.4
Date: Mon, 26 Oct 2015 01:29:55 +0900
Message-ID: <20151025162955.GA8375@kroah.com>
References: <20151023003306.GA25388@kroah.com>
 <562C83FD.6010402@wiesinger.com>
 <20151025082547.GA22300@kroah.com>
 <20151025090308.GA17656@1wt.eu>
 <562CA13C.90500@wiesinger.com>
 <20151025094634.GA6832@1wt.eu>
 <562CB396.2080509@wiesinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@vger.kernel.org, lwn@lwn.net,
	Jiri Slaby <jslaby@suse.cz>
To: Gerhard Wiesinger <lists@wiesinger.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562CB396.2080509@wiesinger.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 25, 2015 at 11:48:54AM +0100, Gerhard Wiesinger wrote:
> On 25.10.2015 10:46, Willy Tarreau wrote:
> >ipset *triggered* the problem. The whole stack dump would tell more.
> 
> OK, find the stack traces in the bug report:
> https://bugzilla.redhat.com/show_bug.cgi?id=1272645
> 
> Kernel 4.1.10 triggered also a kernel dump when playing with ipset commands
> and IPv6, details in the bug report  ....
> 
> >>Kernel 4.2 seems to me not well tested in the netfilter parts at all
> >>(Bug with already known bugfix
> >>https://lists.debian.org/debian-kernel/2015/10/msg00034.html was
> >>triggered on 2 of 3 of my machines, the new bug on 1 of 1 tested machine).
> >There's a reason why Greg maintains stable and LTS kernels :-)
> 
> Stable kernels don't crash but definiton. :-)
> 
> At least triggered 2 kernel panics in 5min, even with 4.1.10 and ipset
> commands ...

Does this happen also with Linus's tree?  I suggest you ask the
networking developers about this on netdev@vger.kernel.org, there's
nothing that I can do on my own about this, sorry.

greg k-h

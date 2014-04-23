From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP
 socket options
Date: Wed, 23 Apr 2014 15:05:32 -0400
Message-ID: <20140423190532.GE22755@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <20140422.160558.627080587952506099.davem@davemloft.net>
 <CALCETrWHA5ZmzOHnz9LO+7v4byc8QiynGyjE_ju5sjokNqrjZA@mail.gmail.com>
 <20140422.162927.2182797573155988911.davem@davemloft.net>
 <CALCETrX_TCbKy-3W590wG3rq9O3Hzbqc_wu3EGg7PKn2NNsTpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrX_TCbKy-3W590wG3rq9O3Hzbqc_wu3EGg7PKn2NNsTpQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 01:31:13PM -0700, Andy Lutomirski wrote:
[..]
> > Otherwise, without SO_PASSCGROUP, there is no way for datagram sockets
> > to find out the peer's open() time cgroup.
> 
> Right.
> 
> I'd still like to know what userspace applications want this feature.
> The canonical example seems to be journald, but journald doesn't use
> unix datagram sockets AFAICS,

Dan Walsh mentiond that systemd also monitors /dev/log (datagram socket) and
logs everything in journal. There this information should be useful.

Thanks
Vivek

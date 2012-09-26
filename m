From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH 02/11] inet_diag: pass inet_diag module to
 netlink_dump_start
Date: Wed, 26 Sep 2012 19:26:14 +0200
Message-ID: <20120926172614.GA22353@1984>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1348635140-20225-2-git-send-email-gaofeng@cn.fujitsu.com>
 <20120926090714.618a4b39@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jengelh-9+2X+4sQBs8@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120926090714.618a4b39-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 26, 2012 at 09:07:14AM -0700, Stephen Hemminger wrote:
> On Wed, 26 Sep 2012 12:52:11 +0800
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
> >  			struct netlink_dump_control c = {
> >  				.dump = inet_diag_dump_compat,
> > +				.done = netlink_dump_done,
> > +				.module = THIS_MODULE,
> >  			};
> 
> Since these are immutable, why the netlink_dump_control structures
> on the stack (which requires code to generate at runtime), and instead
> make them global
> 
> static const struct netlink_dump_control unix_diag_ctrl = {
> ...

I made that code. I can send a patch to statify those
netlink_dump_control structures.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

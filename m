From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] fix missing security_*() check in net/compat.c
Date: Tue, 30 Nov 2004 09:06:34 -0800
Message-ID: <20041130090634.Y2357@build.pdx.osdl.net>
References: <20041130145444.GF63669@gaz.sfgoth.com> <Xine.LNX.4.44.0411301117010.12330-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mitchell Blank Jr <mitch@sfgoth.com>, netdev@oss.sgi.com,
        Chris Wright <chrisw@osdl.org>, Stephen Smalley <sds@epoch.ncsc.mil>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0411301117010.12330-100000@thoron.boston.redhat.com>; from jmorris@redhat.com on Tue, Nov 30, 2004 at 11:17:41AM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> On Tue, 30 Nov 2004, Mitchell Blank Jr wrote:
> 
> > While looking at the SCM passing code in net/core/scm.c I noticed that there's
> > a 32-bit compat implementation of scm_detach_fds()'s called 
> > scm_detach_fds_compat() living in net/compat.c.  While these two functions
> > are mostly the same the latter does not include the call to the
> > security_file_receive() hook which is almost certainly a bug.
> > 
> > My sparc64 test box isn't set up currently so this is not tested.  Someone
> > running a 64-bit kernel with CONFIG_COMPAT should verify that this at
> > least compiles.
> > 
> > Signed-off-by: Mitchell Blank Jr <mitch@sfgoth.com>
> 
> Looks correct to me.
> 
> Signed-off-by: James Morris <jmorris@redhat.com>

Yup, looks fine.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net

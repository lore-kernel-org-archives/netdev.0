From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] fix missing security_*() check in net/compat.c
Date: Tue, 30 Nov 2004 11:17:41 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411301117010.12330-100000@thoron.boston.redhat.com>
References: <20041130145444.GF63669@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Chris Wright <chrisw@osdl.org>,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20041130145444.GF63669@gaz.sfgoth.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004, Mitchell Blank Jr wrote:

> While looking at the SCM passing code in net/core/scm.c I noticed that there's
> a 32-bit compat implementation of scm_detach_fds()'s called 
> scm_detach_fds_compat() living in net/compat.c.  While these two functions
> are mostly the same the latter does not include the call to the
> security_file_receive() hook which is almost certainly a bug.
> 
> My sparc64 test box isn't set up currently so this is not tested.  Someone
> running a 64-bit kernel with CONFIG_COMPAT should verify that this at
> least compiles.
> 
> Signed-off-by: Mitchell Blank Jr <mitch@sfgoth.com>

Looks correct to me.

Signed-off-by: James Morris <jmorris@redhat.com>



-- 
James Morris
<jmorris@redhat.com>

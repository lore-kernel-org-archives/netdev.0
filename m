From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using SELinux and SOCK_SEQPACKET
Date: Wed, 17 Nov 2004 22:07:59 -0800
Message-ID: <20041117220756.N2357@build.pdx.osdl.net>
References: <Xine.LNX.4.44.0411172222160.2531-100000@thoron.boston.redhat.com> <Xine.LNX.4.44.0411172323260.2700-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0411172323260.2700-100000@thoron.boston.redhat.com>; from jmorris@redhat.com on Wed, Nov 17, 2004 at 11:25:39PM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> On Wed, 17 Nov 2004, James Morris wrote:
> 
> > There is a non SELinux-related bug lurking in this code.
> 
> I also got this when trying to kill the server (which seems to run at 100% 
> during exit after receving a message sent with sendto() + address):

I was seeing similar with my test (w/out SELinux), but got garbage for
back trace.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net

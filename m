From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 10:34:11 -0800
Message-ID: <20041118103411.P2357@build.pdx.osdl.net>
References: <Xine.LNX.4.44.0411172222160.2531-100000@thoron.boston.redhat.com> <1100796294.6019.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@redhat.com>,
        Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1100796294.6019.8.camel@localhost.localdomain>; from alan@lxorguk.ukuu.org.uk on Thu, Nov 18, 2004 at 04:45:14PM +0000
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> On Iau, 2004-11-18 at 03:42, James Morris wrote:
> > > Well, my reading of socket(2) suggests that it's _not_ supposed to work.
> > 
> > sendto() on a non connected socket should fail with ENOTCONN.
> 
> Not entirely true at all. A network protocol can implement lazy binding
> and
> do implicit binding on the sendto. Other protocols might not actually
> have
> a receiving component so have no bind() functionality at all.

Just to be clear, this fix is not at socket layer, but specific to UNIX
domain socket protocol layer.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net

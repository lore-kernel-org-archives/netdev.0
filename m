From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 23:01:09 -0800
Message-ID: <20041118230109.V2357@build.pdx.osdl.net>
References: <1100821144.6005.40.camel@localhost.localdomain> <Xine.LNX.4.44.0411182207080.7831-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Ross Kendall Axe <ross.axe@blueyonder.co.uk>,
	netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261265AbUKSHBW@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0411182207080.7831-100000@thoron.boston.redhat.com>; from jmorris@redhat.com on Thu, Nov 18, 2004 at 10:12:13PM -0500
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> On Thu, 18 Nov 2004, Alan Cox wrote:
> 
> > As to the other stuff I think the only change needed is to check the
> > queued asynchronous error and report that before going on to the
> > connected test
> 
> How about this?

The other patch is already committed, so relative diff would be needed.

> (Also now ignores any supplied address per 
> http://www.opengroup.org/onlinepubs/009695399/functions/sendto.html)

Nitpick, but I missed where it said ignore the address.  And it seems
counter intuitive to provide address, only to have it ignored and
delivered elsewhere.

thanks,
-chris

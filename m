From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 13:20:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801132037.3f3542ae.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030801162536.GA18574@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Aug 2003 12:25:36 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> On Fri, Aug 01, 2003 at 04:46:56PM +0100, Matthew Wilcox wrote:
> > On Fri, Aug 01, 2003 at 11:40:21AM -0400, Jeff Garzik wrote:
> > > Comments:
> > > 
> > > * need SET_ETHTOOL_OPS macro or HAVE_ETHTOOL_OPS test macro or similar
> > 
> > DaveM disagreed with that...
> 
> It's standard netdevice.h practice, and, he didn't disagree w/ my
> rebuttal.
> 
> It is needed.

Absolutely not, it makes no sense whatsoever to have this.

Jeff, stop and think.

The whole _POINT_ of these ops are to avoid duplicated code.
If someone is absolutely adament about supporting kernels
without ops support they should not support it at all.

The point is to avoid code duplication, but what you suggest can only
be used to keep the duplicated code around "just in case".  This makes
exactly no sense at all, it severs only to defeat the whole purpose
of the change in the first place.

I totally am against making an ifdef test available for this, it can
only result in illogical things being done by driver maintainers.

From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.4.28-pre3] 3c59x: resync with 2.6
Date: Fri, 8 Oct 2004 13:26:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008132603.G14378@tuxdriver.com>
References: <20041008121307.C14378@tuxdriver.com> <20041008191324.J17999@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, akpm@osdl.org,
        jgarzik@pobox.com, marcelo.tosatti@cyclades.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <20041008191324.J17999@flint.arm.linux.org.uk>; from rmk+lkml@arm.linux.org.uk on Fri, Oct 08, 2004 at 07:13:24PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 08, 2004 at 07:13:24PM +0100, Russell King wrote:
> On Fri, Oct 08, 2004 at 12:13:07PM -0400, John W. Linville wrote:
> > Backport of current 3c59x driver (minus EISA/sysfs stuff) from 2.6 to
> > 2.4.  This should ease further maintenance in 2.4.
> > ---
> > I've been chasing some 3c59x driver problems on both 2.4.x and 2.6.x
> > kernels.  The 3c59x driver was pretty far out of sync between the two
> > trees, so I thought it made sense to sync them back up.
> 
> Ah, if someone's looking at the 3c59x driver then please look into the
> NWAY autonegotiation code - even maybe update it to use mii.c.

Russell,

If you can help to get my patches applied, then I'll be happy to look at
this for you... :-)

BTW, does this sound like the same issue:

http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=75813

John
-- 
John W. Linville
linville@tuxdriver.com

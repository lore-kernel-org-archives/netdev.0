From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6.0-test11] Net device error logging
Date: Sat, 6 Dec 2003 01:04:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031206090414.GA23445@kroah.com>
References: <3FD0E1FE.1D5B1883@us.ibm.com> <3FD0E498.8070703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jim Keniston <jkenisto@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>,
        "Feldman, Scott" <scott.feldman@intel.com>,
        Larry Kessler <kessler@us.ibm.com>,
        "David S. Miller" <davem@redhat.com>,
        Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FD0E498.8070703@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 03:03:36PM -0500, Jeff Garzik wrote:
> I discussed this a bit with David.  My personal feelings are that I 
> prefer just leaving all the printk's as they are.  But Linus and GregKH 
> have been accepting patches into other parts of the tree like this one, 
> and logging additional already-computer-parsed information is probably 
> not a bad thing long-term, so perhaps I've been being a bit of a Luddite 
> on this issue.

To be fair, the patches I've taken (dev_err and friends) are _much_
simpler than these, so accepting them was not that big of a deal.  It
enabled the subsystems that have started to use them (USB and I2C) to
log better messages (we now know exactly which device caused the errors,
instead of just which driver).

So please judge this patch on its own, and feel no pressure due to the
dev_*() calls :)

thanks,

greg k-h

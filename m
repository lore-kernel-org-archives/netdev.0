From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 2 Oct 2009 09:10:49 -0700
Message-ID: <20091002161048.GA23044@kroah.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
	<20091002135859.GA9383@kroah.com>
	<200910021754.12940.philipp.reisner@linbit.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fbdev-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <200910021754.12940.philipp.reisner@linbit.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2009 at 05:54:12PM +0200, Philipp Reisner wrote:
> > On Fri, Oct 02, 2009 at 02:40:03PM +0200, Philipp Reisner wrote:
> > > Affected: All code that uses connector, in kernel and out of mainline
> > >
> > > The connector, as it is today, does not allow the in kernel receiving
> > > parts to do any checks on privileges of a message's sender.
> >
> > So, assume I know nothing about the connector architecture, what does
> > this mean in a security context?
> >
> 
> Think of the connector as a layer on top of netlink that allows more
> than a hard coded number of subsystems to use netlink.
> 
> Netlink is used e.g. to modify routing tables in the kernel.
> 
> As it is today, subsystem utilising the connector can not examine
> the capabilities of the user/program that sent the netlink message.
> 
> If the same would be true for netlink, than every unprivileged user
> could change the routing tables on your box.
> 
> > > I know, there are not many out there that like connector, but as
> > > long as it is in the kernel, we have to fix the security issues it has!
> >
> > And what specifically are the security issues?
> >
> 
> unprivileged users can trigger operations that are supposed to be only
> accessible to users having CAP_SYS_ADMIN (or some other CAP_XXX)

Ok, but it doesn't look like there are that many connector operations
right now, right?

Anyway, I have no objection to the patches, and figure they should go
through David's network tree.

thanks,

greg k-h

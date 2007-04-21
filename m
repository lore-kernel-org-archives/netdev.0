From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/7] [IrDA] IrDA monitor mode
Date: Sat, 21 Apr 2007 10:46:00 -0700 (PDT)
Message-ID: <20070421.104600.30183443.davem@davemloft.net>
References: <20070418214751.455457680@sortiz.org>
	<20070420.221143.132446079.davem@davemloft.net>
	<20070421114239.GA4337@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20070421114239.GA4337-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Date: Sat, 21 Apr 2007 14:42:40 +0300

> I actually asked for your advice about it some time ago:
> http://marc.info/?l=linux-netdev&m=117590341703544&w=2
> But by looking at the flow of emails on netdev sent to you (and that's only
> netdev...), I can easily see how you could have missed it :-)
> 
> Regarding this patch, I came up with this ioctl because I thought
> implementing an IrDA netlink layer would be an overkill for just one single
> command.
> What I propose is that you revert this patch before we introduce a new ioctl
> upstream while I start implementing a netlink IrDA layer. Would that be ok
> with you, or can we let this new ioctl in and have it coexisting with a future
> netlink layer ?

The only concern is that once we add the ioctl, we can't get rid of
it, it's there forever.  Please consider this very carefully.

You might discover that once you create the IRDA netlink
layer, you will find it convenient to make it support
all the IRDA stack configuration not just this one thing
:-)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

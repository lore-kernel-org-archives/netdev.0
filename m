From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/7] [IrDA] IrDA monitor mode
Date: Sat, 21 Apr 2007 14:42:40 +0300
Message-ID: <20070421114239.GA4337@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
	<20070418214751.455457680@sortiz.org>
	<20070420.221143.132446079.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070420.221143.132446079.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Hi Dave,

On Fri, Apr 20, 2007 at 10:11:43PM -0700, David Miller wrote:
> From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
> Date: Thu, 19 Apr 2007 00:32:07 +0300
> 
> > Through a protocol specific ioctl, one can disable IrDA TX in order to
> > monitor an IrDA link.
> > 
> > Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
> 
> I'd really rather see IRDA use netlink instead of these
> wonky ioctls, but whatever, if you want to put this dirty
> into your stack and you're the maintainer I can't really
> stop you :-)
I actually asked for your advice about it some time ago:
http://marc.info/?l=linux-netdev&m=117590341703544&w=2
But by looking at the flow of emails on netdev sent to you (and that's only
netdev...), I can easily see how you could have missed it :-)

Regarding this patch, I came up with this ioctl because I thought
implementing an IrDA netlink layer would be an overkill for just one single
command.
What I propose is that you revert this patch before we introduce a new ioctl
upstream while I start implementing a netlink IrDA layer. Would that be ok
with you, or can we let this new ioctl in and have it coexisting with a future
netlink layer ?

Cheers,
Samuel.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

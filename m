From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver
 model)
Date: Thu, 13 Jan 2005 09:02:50 -0800
Message-ID: <20050113090250.15444e09@dxpl.pdx.osdl.net>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com>
	<A3A281FF-5525-11D9-80ED-000393C30512@freescale.com>
	<D3652CF8-6571-11D9-821C-000393DBC2E8@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        Andy
 Fleming <afleming@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kumar Gala <kumar.gala@freescale.com>
In-Reply-To: <D3652CF8-6571-11D9-821C-000393DBC2E8@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Jan 2005 08:45:53 -0600
Kumar Gala <kumar.gala@freescale.com> wrote:

> Jeff,
> 
> We were hoping for more feedback from netdev people on this patch:
> 
> http://oss.sgi.com/projects/netdev/archive/2004-12/msg00643.html
> 
> thanks
> 
> - kumar
> 
> On Dec 23, 2004, at 3:00 PM, Andy Fleming wrote:
> 
> > It has been suggested that I split the patch into 2 parts: gianfar
> > specific stuff, and PHY specific stuff.
> >
> > Here is the result:
> > <gfar_12232004.patch><phy_12232004.patch><ATT229010.txt>
> 

It would be more valuable if there were cases where multiple different boards that
use the same type of PHY chip were supported. Even better if it could subsume the existing
MII code. Don't know enough about all the different flavors of hardware to know what
combinations exist but it looks like there are different boards that have the same
PHY chips. It looks like the FreeBSD tries to abstract this.

-- 
Stephen Hemminger	<shemminger@osdl.org>

From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Patch] netconsole: do not depend on experimental
Date: Mon, 22 Mar 2010 17:17:43 -0500
Message-ID: <1269296263.3552.5.camel@calx>
References: <20100322100305.5518.29500.sendpatchset@localhost.localdomain>
	 <20100322125919.GB4288@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:36564 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755575Ab0CVWRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 18:17:48 -0400
In-Reply-To: <20100322125919.GB4288@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-22 at 08:59 -0400, Neil Horman wrote:
> On Mon, Mar 22, 2010 at 05:59:23AM -0400, Amerigo Wang wrote:
> > 
> > Nowadays, most distributions enable netconsole by default,
> > including RHEL, Fedora, Debian, Arch, Opensuse. And
> > we don't have any bug reports about it. So I think there
> > is no need to mark it as experimental any more.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: WANG Cong <amwang@redhat.com>
> > 
> > ---
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index 0ba5b8e..e3d6c52 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -3252,15 +3252,14 @@ config NET_FC
> >  	  "SCSI generic support".
> >  
> >  config NETCONSOLE
> > -	tristate "Network console logging support (EXPERIMENTAL)"
> > -	depends on EXPERIMENTAL
> > +	tristate "Network console logging support"
> >  	---help---
> >  	If you want to log kernel messages over the network, enable this.
> >  	See <file:Documentation/networking/netconsole.txt> for details.
> >  
> >  config NETCONSOLE_DYNAMIC
> > -	bool "Dynamic reconfiguration of logging targets (EXPERIMENTAL)"
> > -	depends on NETCONSOLE && SYSFS && EXPERIMENTAL
> > +	bool "Dynamic reconfiguration of logging targets"
> > +	depends on NETCONSOLE && SYSFS
> >  	select CONFIGFS_FS
> >  	help
> >  	  This option enables the ability to dynamically reconfigure target
> > --
> 
> Seems reasonable.  Netconsole seems pretty mature.
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Yeah, I'd forgotten that flag was even there.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux



From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 2/5] s2io driver updates
Date: Mon, 24 Apr 2006 10:22:03 -0700
Message-ID: <20060424102203.3cb5e29b@localhost.localdomain>
References: <Pine.GSO.4.10.10604211903180.15266-100000@guinness>
	<20060422092802.GD26666@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ananda Raju <Ananda.Raju@neterion.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, leonid.grossman@neterion.com,
	ravinandan.arakali@neterion.com, rapuru.sriram@neterion.com,
	alicia.pena@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31701 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751001AbWDXRWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 13:22:51 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060422092802.GD26666@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 22 Apr 2006 11:28:02 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Ananda Raju <Ananda.Raju@neterion.com> :
> [...]
> > Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
> > ---
> > diff -upNr perf_fixes/drivers/net/s2io.c dmesg_param_fixes/drivers/net/s2io.c
> > --- perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
> > +++ dmesg_param_fixes/drivers/net/s2io.c	2006-04-13 09:08:22.000000000 -0700
> [...]
> > @@ -4626,6 +4633,45 @@ static int write_eeprom(nic_t * sp, int 
> >  	return ret;
> >  }
> >  
> > +static void s2io_vpd_read(nic_t *nic)
> > +{
> > +	u8 vpd_data[256],data;
> 
> You may consider removing vpd_data from the stack and kmallocing it.
> 

Since there lsvpd tool doesn't in user space, why add more kernel code
to do it?  Adding more code to just print prettier console log's is bogus.

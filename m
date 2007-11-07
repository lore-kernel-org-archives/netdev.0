From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 09:33:38 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBEF@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE2@XCH-NW-7V2.nw.nos.boeing.com> <20071107093128.4985c446@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:54985 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758890AbXKGRdx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 12:33:53 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071107093128.4985c446@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, and will fix.

Fred 

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@linux-foundation.org] 
> Sent: Wednesday, November 07, 2007 9:31 AM
> To: Templin, Fred L
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 01/05] ipv6: RFC4214 Support
> 
> On Tue, 6 Nov 2007 17:16:01 -0800
> "Templin, Fred L" <Fred.L.Templin@Boeing.com> wrote:
> 
> > From: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > This is experimental support for the Intra-Site Automatic
> > Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> > the SIT module, and is configured using the unmodified
> > "ip" utility with device names beginning with: "isatap".
> > 
> > The following diffs are specific to the Linux 2.6.23
> > kernel distribution.
> > 
> > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > ---
> > 
> > --- linux-2.6.23/include/linux/if.h.orig	2007-10-29
> > 09:22:26.000000000 -0700
> > +++ linux-2.6.23/include/linux/if.h	2007-10-26 11:00:06.000000000
> > -0700
> > @@ -61,6 +61,9 @@
> >  #define IFF_MASTER_ALB	0x10		/* bonding 
> master, balance-alb.
> > */
> >  #define IFF_BONDING	0x20		/* bonding 
> master or slave
> > */
> >  #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs 
> for validation
> > */
> > +#if defined(CONFIG_IPV6_ISATAP)
> > +#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)
> > */
> > +#endif
> >  
> 
> Don't make this conditional.. You always want the number assigned
> and available, plus this file is used from user space where kernel
> configuration is unknown or irrelevant.
> 
> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>
> 

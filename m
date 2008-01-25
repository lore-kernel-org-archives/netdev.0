From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v2] PS3: gelic: Add wireless support for PS3
Date: Thu, 24 Jan 2008 21:47:25 -0500
Message-ID: <20080125024725.GB3411@tuxdriver.com>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <20080124144253.6176.40F06B3A@sm.sony.co.jp> <1201225785.15917.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1201225785.15917.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2008 at 08:49:45PM -0500, Dan Williams wrote:
> On Thu, 2008-01-24 at 14:51 +0900, Masakazu Mokuno wrote:
> > Hi
> > 
> > PS3: gelic: Add wireless support for PS3
> > 
> > This is the version 2 of the re-worked (rewritten) version of the
> > wireless support driver for PS3.  The version 1 of the new driver was
> > submitted on 13th Dec. 2007 (and the old one was submitted to net-dev ML
> > in June 2007).
> > 
> > Major differences with the old driver are:
> >   - The new driver has a separate ethX interface from ethernet.
> >     They share the same MAC address.
> >   - Thus we can use both ethernet and wireless simultaenously.
> >   - The new driver returns AP's cipher information by the common IE
> >     format in the scan information.
> >   - Cipher selection is done via the common wireless extension way
> 
> Looks like all my issues have been addressed.  Thanks!  Lets get this in
> 2.6.25 :)
> 
> Acked-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

ACK -- please merge it with the other patches through the powerpc tree.

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org

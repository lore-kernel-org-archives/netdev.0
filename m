From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH v2] PS3: gelic: Add wireless support for PS3
Date: Fri, 25 Jan 2008 12:36:38 +0900
Message-ID: <20080125122408.5CC6.40F06B3A@sm.sony.co.jp>
References: <1201225785.15917.8.camel@localhost.localdomain> <20080125024725.GB3411@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080125024725.GB3411-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 24 Jan 2008 21:47:25 -0500
"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:

> On Thu, Jan 24, 2008 at 08:49:45PM -0500, Dan Williams wrote:
> > On Thu, 2008-01-24 at 14:51 +0900, Masakazu Mokuno wrote:
> > > Hi
> > > 
> > > PS3: gelic: Add wireless support for PS3
> > > 
> > > This is the version 2 of the re-worked (rewritten) version of the
> > > wireless support driver for PS3.  The version 1 of the new driver was
> > > submitted on 13th Dec. 2007 (and the old one was submitted to net-dev ML
> > > in June 2007).
> > > 
> > > Major differences with the old driver are:
> > >   - The new driver has a separate ethX interface from ethernet.
> > >     They share the same MAC address.
> > >   - Thus we can use both ethernet and wireless simultaenously.
> > >   - The new driver returns AP's cipher information by the common IE
> > >     format in the scan information.
> > >   - Cipher selection is done via the common wireless extension way
> > 
> > Looks like all my issues have been addressed.  Thanks!  Lets get this in
> > 2.6.25 :)
> > 
> > Acked-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> ACK -- please merge it with the other patches through the powerpc tree.
> 
> Thanks,
> 
> John

Thank you, John, Dan.

I'll ask Paul to merge this if the wired part of dependent gelic patches
gets acked from network people.


-- 
Masakazu MOKUNO

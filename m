From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v3 1/2] realtek: convert to per-chip mask
Date: Fri, 09 Aug 2013 11:58:24 +0200
Message-ID: <2677928.0eNgS5TqmA@al>
References: <1374759391-16916-1-git-send-email-lekensteyn@gmail.com> <6171378.LP1RDUmkgD@al> <1376041490.14810.5.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44056 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965280Ab3HIJ62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 05:58:28 -0400
Received: by mail-wi0-f174.google.com with SMTP id j17so1460347wiw.7
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 02:58:27 -0700 (PDT)
In-Reply-To: <1376041490.14810.5.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 August 2013 11:44:50 Ben Hutchings wrote:
> On Fri, 2013-08-09 at 10:51 +0200, Peter Wu wrote:
> > On Thursday 08 August 2013 20:25:41 Ben Hutchings wrote:
> > > On Thu, 2013-07-25 at 15:36 +0200, Peter Wu wrote:
> > > [...]
> > >
> > > 
> > >
> > > > @@ -35,36 +32,62 @@ enum chip_type {
> > > >
> > > > 
> > > >   RTL8100E2,
> > > >  
> > > >  };
> > > > 
> > > >
> > > > -enum {
> > > > - chip_type_mask = HW_REVID(1, 1, 1, 1, 1, 1, 1, 1)
> > > > +static const char * const chip_names[] = {
> > > > + [RTL8139] =             "8139",
> > > > + [RTL8139_K] =           "8139-K",
> > > > + [RTL8139A] =            "8139A",
> > > > + [RTL8139A_G] =          "8139A-G",
> > > > + [RTL8139B] =            "8139B",
> > > > + [RTL8130] =             "8130",
> > > > + [RTL8139C] =            "8139C",
> > > > + [RTL8100] =             "8100",
> > > > + [RTL8100B_8139D] =      "8100B/8139D",
> > > > + [RTL8139C] =            "8139C+",
> > >
> > > 
> > >
> > > Shouldn't the index here be RTL8139Cp?
> >
> > 
> >
> > The specifications mention "RTL8139C+", I took pre-8169 names from the
> > previous 
> > rtl_info_tbl contents:
> [...]
> 
> I'm talking about the index, not the name.  This has an index of
> RTL8139C which is also used 3 lines up.

Oh oops, my sed expression missed this one. I'll fix this in the next version.

Regards,
Peter

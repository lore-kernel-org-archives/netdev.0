From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: sh: add support for ax88796 and 93cx6 to highlander boards
Date: Wed, 12 Sep 2007 14:21:49 +0900
Message-ID: <aec7e5c30709112221v509af4b9xcdcb4dd91427d7ee@mail.gmail.com>
References: <20070910063626.2300.75144.sendpatchset@clockwork.opensource.se>
	 <20070910071528.GB13672@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, ben-linux@fluff.org
To: "Paul Mundt" <lethal@linux-sh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:36204 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764207AbXILFVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 01:21:50 -0400
Received: by py-out-1112.google.com with SMTP id u77so189254pyb
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 22:21:50 -0700 (PDT)
In-Reply-To: <20070910071528.GB13672@linux-sh.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/10/07, Paul Mundt <lethal@linux-sh.org> wrote:
> On Mon, Sep 10, 2007 at 03:36:26PM +0900, Magnus Damm wrote:
> > --- 0001/drivers/net/Kconfig
> > +++ work/drivers/net/Kconfig  2007-09-06 15:35:41.000000000 +0900
> > @@ -218,13 +218,20 @@ source "drivers/net/arm/Kconfig"
> >
> >  config AX88796
> >       tristate "ASIX AX88796 NE2000 clone support"
> > -     depends on ARM || MIPS
> > +     depends on ARM || MIPS || SUPERH
> >       select CRC32
> >       select MII
> >       help
> >         AX88796 driver, using platform bus to provide
> >         chip detection and resources
> >
> > +config AX88796_93CX6
> > +     bool "ASIX AX88796 external 93CX6 eeprom support"
> > +     depends on AX88796
> > +     select EEPROM_93CX6
> > +     help
> > +       Select this if your platform comes with an external 93CX6 eeprom.
> > +
> >  config MACE
> >       tristate "MACE (Power Mac ethernet) support"
> >       depends on PPC_PMAC && PPC32
>
> There are two different changes here, these should probably be split up
> and applied independently of each other, given that there's no real
> dependency between them.

Sure. I hope to first get some feedback regarding the AX88796 specific
parts of the patch, then i'll split it up and repost. Getting this one
included in 2.6.24 would be nice if possible.

Thanks,

/ magnus

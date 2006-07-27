From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] forcedeth: coding style cleanups (rev2)
Date: Thu, 27 Jul 2006 21:29:53 +0200
Message-ID: <200607272129.53773.mb@bu3sch.de>
References: <20060727161945.204688818@localhost> <200607272121.14459.mb@bu3sch.de> <20060727122429.27fcd513@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:26081
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751861AbWG0Tam
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 15:30:42 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060727122429.27fcd513@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 July 2006 21:24, Stephen Hemminger wrote:
> On Thu, 27 Jul 2006 21:21:14 +0200
> Michael Buesch <mb@bu3sch.de> wrote:
> 
> > On Thursday 27 July 2006 19:48, Stephen Hemminger wrote:
> > > --- sky2.orig/drivers/net/forcedeth.c	2006-07-13 12:53:48.000000000 -0700
> > > +++ sky2/drivers/net/forcedeth.c	2006-07-27 10:45:49.000000000 -0700
> > > @@ -381,21 +381,21 @@
> > >  
> > >  /* Big endian: should work, but is untested */
> > >  struct ring_desc {
> > > -	u32 PacketBuffer;
> > > -	u32 FlagLen;
> > > +	u32 buf;
> > > +	u32 flaglen;
> > >  };
> > >  
> > >  struct ring_desc_ex {
> > > -	u32 PacketBufferHigh;
> > > -	u32 PacketBufferLow;
> > > -	u32 TxVlan;
> > > -	u32 FlagLen;
> > > +	u32 bufhigh;
> > > +	u32 buflow;
> > > +	u32 txvlan;
> > > +	u32 flaglen;
> > >  };
> > 
> > Shouldn't these two structs be __attribute__((packed)) ?
> > 
> 
> Not really necessary since the elements are all the same size.

Yes, sure. But I always ask myself if we really want to depend on this.
(There are other drivers also depending on this...)

I would say, if the device depends on the fields being
there without padding, we should tell the compiler.

> Plus, this was a style cleanup patch...

Sure. Was more a generic comment from me. ;)

-- 
Greetings Michael.

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] forcedeth: coding style cleanups (rev2)
Date: Thu, 27 Jul 2006 12:24:29 -0700
Message-ID: <20060727122429.27fcd513@localhost.localdomain>
References: <20060727161945.204688818@localhost>
	<20060727162051.090728791@localhost>
	<20060727104811.1c00e938@localhost.localdomain>
	<200607272121.14459.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65209 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751870AbWG0TZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 15:25:42 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607272121.14459.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2006 21:21:14 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> On Thursday 27 July 2006 19:48, Stephen Hemminger wrote:
> > --- sky2.orig/drivers/net/forcedeth.c	2006-07-13 12:53:48.000000000 -0700
> > +++ sky2/drivers/net/forcedeth.c	2006-07-27 10:45:49.000000000 -0700
> > @@ -381,21 +381,21 @@
> >  
> >  /* Big endian: should work, but is untested */
> >  struct ring_desc {
> > -	u32 PacketBuffer;
> > -	u32 FlagLen;
> > +	u32 buf;
> > +	u32 flaglen;
> >  };
> >  
> >  struct ring_desc_ex {
> > -	u32 PacketBufferHigh;
> > -	u32 PacketBufferLow;
> > -	u32 TxVlan;
> > -	u32 FlagLen;
> > +	u32 bufhigh;
> > +	u32 buflow;
> > +	u32 txvlan;
> > +	u32 flaglen;
> >  };
> 
> Shouldn't these two structs be __attribute__((packed)) ?
> 

Not really necessary since the elements are all the same size.
Plus, this was a style cleanup patch...

From: Sharma Bhupesh-B45370 <B45370@freescale.com>
Subject: RE: Query: Regarding 8211E Phy module support in drivers/net/phy
Date: Fri, 30 Aug 2013 11:18:49 +0000
Message-ID: <A1A6EA40F8503D48BB002B42BD65974E0A144FCB@039-SN2MPN1-012.039d.mgd.msft.net>
References: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
 <520B8F2C.5090308@st.com>
 <A1A6EA40F8503D48BB002B42BD65974E0A111CD2@039-SN2MPN1-013.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:51621
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754615Ab3H3LSy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 07:18:54 -0400
In-Reply-To: <A1A6EA40F8503D48BB002B42BD65974E0A111CD2@039-SN2MPN1-013.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

Ping.. Any updates on this?

> -----Original Message-----
> From: Sharma Bhupesh-B45370
> Sent: Thursday, August 15, 2013 1:48 AM
> To: 'Giuseppe CAVALLARO'
> Cc: 'netdev@vger.kernel.org'
> Subject: RE: Query: Regarding 8211E Phy module support in drivers/net/phy
> 
> 
> > -----Original Message-----
> > From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> > Sent: Wednesday, August 14, 2013 7:38 PM
> > To: Sharma Bhupesh-B45370
> > Cc: 'netdev@vger.kernel.org'
> > Subject: Re: Query: Regarding 8211E Phy module support in
> > drivers/net/phy
> >
> > On 8/2/2013 8:50 PM, Sharma Bhupesh-B45370 wrote:
> > > Hi Peppe,
> > >
> > > This regarding the patch prepared by you for adding RTL8211E support
> > > in drivers/net/phy/realtek.c
> > >
> > > commit ef3d90491a15f0d5cf1ec39a38a45dac6968fb2a
> > > Author: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> > > Date:   Wed Jan 23 00:30:03 2013 +0000
> > >
> > >      net: phy: realtek: add rtl8211e driver
> > >
> > >      This patch adds the minimal driver to manage the
> > >      Realtek RTL8211E 10/100/1000 Transceivers.
> > >
> > > I see a macro specific to 8211E:
> > > +#define        RTL8211E_INER_LINK_STAT 0x10
> > >
> > > I was having a look at the RTL8211E(G) datasheet and could see the
> > > following bit positions for INER register (Address 0x12):
> > >
> > > [7:1] as Reserved
> > > [0] as Jabber Interrupt
> > >
> > > If I am not wrong a value 0x10 written to the INER register tries to
> > > set bit [4] which seems Reserved.
> >
> > Hello Sharma
> > you are right RTL8211E_INER_LINK_STAT should be 0x400 I will test it
> > again (just to find the hw) and prepare/send a new patch.
> >
> 
> Hi Peppe,
> 
> Glad to hear from you. Please test with the h/w and send the relevant
> patch as I plan to send a patch supporting a new RTL phy module rebased
> on top of your patch.
> 
> Thanks for your help.
> Regards,
> Bhupesh
> 
> 
> > Many thanks
> >
> > peppe
> >
> > >
> > > Or am I missing something here.
> > > Please let me know your views on the same.
> > >
> > > Thanks,
> > > Bhupesh
> > >
> > >
> > >
> >

Regards,
Bhupesh

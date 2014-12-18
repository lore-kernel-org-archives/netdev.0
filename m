From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Documentation: clarify phys_port_id
Date: Thu, 18 Dec 2014 09:35:26 -0600
Message-ID: <1418916926.2086.6.camel@dcbw.local>
References: <CAEPrYjTZ8SU1y4TwKHYtZju+4_-O5mazAjaFKaKmR2cYuAKHnA@mail.gmail.com>
	 <1418834826.1160.35.camel@dcbw.local> <1418835576.1160.38.camel@dcbw.local>
	 <CF9D1877D81D214CB0CA0669EFAE020C68D36E70@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joshua Watt <jpewdev@gmail.com>,
	"jpirko@redhat.com" <jpirko@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaLRPfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 10:35:31 -0500
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68D36E70@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-18 at 05:57 +0000, Sathya Perla wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > 
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > ---
> >  Documentation/ABI/testing/sysfs-class-net | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/Documentation/ABI/testing/sysfs-class-net
> > b/Documentation/ABI/testing/sysfs-class-net
> > index e1b2e78..7fe823a 100644
> > --- a/Documentation/ABI/testing/sysfs-class-net
> > +++ b/Documentation/ABI/testing/sysfs-class-net
> > @@ -186,7 +186,12 @@ KernelVersion:	3.12
> >  Contact:	netdev@vger.kernel.org
> >  Description:
> >  		Indicates the interface unique physical port identifier within
> > -		the NIC, as a string.
> > +		the NIC, as a string.  If two net_device objects share physical
> > +		hardware or other resources, and/or do not operate
> > independently
> > +		both net_device objects should be assigned the
> > +		same phys_port_id.  phys_port_id should be as globally
> > unique
> > +		as possible to prevent conflicts between different drivers
> > and
> > +		vendors, eg with MAC addresses or hardware GUIDs.
> 
> Dan, two interfaces -- on the same card/chip -- may share some chip resources,
> but as long as they use *separate* physical ports, it would be OK to bond them.
> So, in this case, it would be valid to report a different phys_port_id for these netdevs.
> 
> The text -- "share physical hardware or other resources" becomes too restrictive
>                                                                           ^^^^^^^^^^^^^^^
> and will not even allow bonding of two physical ports on a NIC card.

Fair enough, I will reword and resubmit.

Dan

> thks,
> -Sathya
> > 
> >  What:		/sys/class/net/<iface>/speed
> >  Date:		October 2009
> > --
> > 1.9.3
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

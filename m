From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38862] New: No support for DGE-530T Rev C1
Date: Wed, 6 Jul 2011 15:07:42 -0700
Message-ID: <20110706150742.2f8afc28@nehalam.ftrdhcpuser.net>
References: <bug-38862-10286@https.bugzilla.kernel.org/>
	<20110706143709.0f5ab7d6.akpm@linux-foundation.org>
	<4E14D83C.1090506@ruggedcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: James Henderson <JamesHenderson@ruggedcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58509 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568Ab1GFWIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 18:08:18 -0400
In-Reply-To: <4E14D83C.1090506@ruggedcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jul 2011 17:48:44 -0400
James Henderson <JamesHenderson@ruggedcom.com> wrote:

> Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > On Wed, 6 Jul 2011 16:05:36 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> >
> >   
> >> https://bugzilla.kernel.org/show_bug.cgi?id=38862
> >>
> >>            Summary: No support for DGE-530T Rev C1
> >>            Product: Drivers
> >>            Version: 2.5
> >>     Kernel Version: 2.6.39.2
> >>           Platform: All
> >>         OS/Version: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: Network
> >>         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >>         ReportedBy: jameshenderson@ruggedcom.com
> >>         Regression: No
> >>
> >>
> >> The kernel support DGE-530T REV B2 through the skge driver.  The PCI device id
> >> of REV-B2 is 1186:4302.  Rev C1 has a PCI device id of 1186:4302.  No driver in
> >> the current kernel supports this device id/vendor combination.  Furthermore,
> >> this device is not even listed in the device database ->
> >> http://www.pcidatabase.com/vendor_details.php?id=921 .
> >>
> >> On the chip is the following information:
> >> D-Link
> >> DLG10028C
> >> A8A34A1
> >> GA50 TAIWAN
> >>
> >> A sticker on the card reads:
> >> DGE-530T Rev C1
> >>
> >> I am including a picture I took of the card.
> >>
> >>     
> >
> > Did you test simply adding that device to the driver?
> >
> > --- a/drivers/net/skge.c~a
> > +++ a/drivers/net/skge.c
> > @@ -89,6 +89,7 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
> > +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	/* DGE-530T Rev C1 */
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
> > _

I will go look at the Marvell Syskonnect driver, they occasionally
up date it with new ID's.


From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next 2/5] be2net: use common method to check for
 sriov function type
Date: Thu, 7 Apr 2011 12:25:31 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD3948@EXMAIL.ad.emulex.com>
References: <20110407040801.GA4199@akhaparde-VBox>
	 ,<1302164041.5282.3.camel@localhost>
	 <49395329523DD64492581B505F80C86D5A5BCD3946@EXMAIL.ad.emulex.com>,<1302183459.2878.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:6993 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756591Ab1DGTZw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 15:25:52 -0400
In-Reply-To: <1302183459.2878.7.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
From: Ben Hutchings [bhutchings@solarflare.com]
Sent: Thursday, April 07, 2011 8:37 AM
To: Khaparde, Ajit
Cc: netdev@vger.kernel.org
Subject: RE: [PATCH net-next 2/5] be2net: use common method to check for sriov function type

On Thu, 2011-04-07 at 05:34 -0700, Ajit.Khaparde@Emulex.Com wrote:
> ________________________________________
> > From: Ben Hutchings [bhutchings@solarflare.com]
> > Sent: Thursday, April 07, 2011 3:14 AM
> > To: Khaparde, Ajit
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH net-next 2/5] be2net: use common method to check for sriov function type
>
> > On Wed, 2011-04-06 at 23:08 -0500, Ajit Khaparde wrote:
> >> Lancer and BE can both use SLI_INTF_REG to check a VF or a PF.
> > [...]
>
> > This seems pretty unreliable (both in the previous and the current
> > version).  You cannot rely on the whole of PCI config space being mapped
> > to a VM guest.  KVM certainly didn't do this when I used PCI pass-
> > through.
>
> That's interesting. I have been using the new method for a while now.
> And the older one has worked pretty well for a long time.
> Can you give some details about the adapter used?
> Let's start with the firmware version, lspci output.

> I've tried this with PFs on Solarflare adapters.

> The capability list is significantly changed.  The hex dump seems to
> show that config space beyond about offset 0x60 is still passed through
> unchanged, but I wouldn't want to rely on that remaining true.

Oh ok. I see some difference in the lspci output on my setup too.
And when I load my driver, the PF is identified properly when I assign it as a passthrough device in a VM.
It does not have the same capability list as in the KVM Hypervisor though.

-Ajit

> Ben.

> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
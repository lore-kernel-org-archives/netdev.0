From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next 2/5] be2net: use common method to check for
 sriov function type
Date: Thu, 7 Apr 2011 05:34:14 -0700
Message-ID: <49395329523DD64492581B505F80C86D5A5BCD3946@EXMAIL.ad.emulex.com>
References: <20110407040801.GA4199@akhaparde-VBox>,<1302164041.5282.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2257 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750886Ab1DGMef convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 08:34:35 -0400
In-Reply-To: <1302164041.5282.3.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
> From: Ben Hutchings [bhutchings@solarflare.com]
> Sent: Thursday, April 07, 2011 3:14 AM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 2/5] be2net: use common method to check for sriov function type

> On Wed, 2011-04-06 at 23:08 -0500, Ajit Khaparde wrote:
>> Lancer and BE can both use SLI_INTF_REG to check a VF or a PF.
> [...]

> This seems pretty unreliable (both in the previous and the current
> version).  You cannot rely on the whole of PCI config space being mapped
> to a VM guest.  KVM certainly didn't do this when I used PCI pass-
> through.

That's interesting. I have been using the new method for a while now.
And the older one has worked pretty well for a long time.
Can you give some details about the adapter used?
Let's start with the firmware version, lspci output.

> Ben.

> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
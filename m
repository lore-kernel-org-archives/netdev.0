From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Fri, 7 Feb 2014 08:44:38 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3054AB528F1@alice.at.omicron.at>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140204092939.GA9862@netboy>
 <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
 <1391527464.7871.15.camel@e37108.spectralink.com>
 <20140204154323.GA2815@netboy>
 <1391586016.7871.23.camel@e37108.spectralink.com>
 <20140207054852.GA4954@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
	=?iso-8859-1?Q?S=F8rensen=2C_Stefan?=
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:51315 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbaBGHvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:51:01 -0500
In-Reply-To: <20140207054852.GA4954@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of Richard Cochran
>Sent: Friday, February 07, 2014 6:49 AM
>To: S=F8rensen, Stefan
>Cc: ben@decadent.org.uk; netdev@vger.kernel.org
>Subject: Re: [PATCH] dp83640: Support a configurable number of periodi=
c
>outputs
>
>On Wed, Feb 05, 2014 at 07:40:17AM +0000, S=F8rensen, Stefan wrote:
>>
>> Will all PTP clocks be associated with an ethernet device? If not,
>> wouldn't a PTP ioctl be better than ethtool?
>
>Hm, maybe. I don't have a strong preference. I'll try and put together=
 an idea
>of how the ioctl might look like.

At least on the Freescale P2020 CPU there is just one PTP clock for 3=20
Ethernet devices. But since the PTP registers are shared between all th=
ree=20
Ethernet ports, an ethtool approach would still work, but seems somehow=
 strange
for me.

Regards,
Manfred

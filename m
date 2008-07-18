From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 1/2] I/OAT: Add watchdog/reset functionality to ioatdma driver
Date: Fri, 18 Jul 2008 17:06:06 +0100
Message-ID: <7F38996F7185A24AB9071ED4950AD8C101D2C640@swsmsx413.ger.corp.intel.com>
References: <487B6004.6090801@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Williams, Dan J" <dan.j.williams@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Brice Goglin" <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11371 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808AbYGRQGM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 12:06:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <487B6004.6090801@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Maciej Sosnowski wrote:
>> Due to occasional DMA channel hangs observed for I/OAT versions 1.2
>> and 2.0 a watchdog has been introduced to check every 2 seconds
>> if all channels progress normally.
>> If stuck channel is detected, driver resets it.
>> The reset is done in two parts. The second part is scheduled
>> by the first one to reinitialize the channel after the restart.
>> 
> 
> Is all this transparent to the caller? Are you reposting all copies to
> the hardware after the reset? Or are we going to get some DMA_ERROR
> return values ?

Yes, it is transparent.
The driver should take care of all the descriptors
that have not been served before the reset.

>> Sleep time in self_test has been increased to 10ms
>> since in some cases 1ms appeared not to be enough
> 
> Thanks Maciej, this helps a lot here.

Sure.

> 
> Brice

Regards,
Maciej

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 12:51:02 -0700
Message-ID: <468562A6.8060901@intel.com>
References: <1183138159.17243.16.camel@blaa> <20070629175006.GB3917@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: Jason Lunz <lunz@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25576 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359AbXF2TvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 15:51:07 -0400
In-Reply-To: <20070629175006.GB3917@falooley.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> On Fri, Jun 29, 2007 at 06:29:18PM +0100, Mark McLoughlin wrote:
>> 	I understand there is some delay in getting e1000-7.5.5 into the
>> upstream kernel given the major re-working of the chipset specific
>> parts.
>>
>> 	I wonder would it be feasible in the meantime to backport the ich9
>> support and push it upstream?
> 
> seconded - this driver reorg has been holding back support for the
> newest e1000 hardware since at least 2.6.20, and I haven't seen any
> indication that the 7.5.5 e1000 driver will even be added to 2.6.23.

I disagree, we should not break the current e1000 driver in the kernel while 
there is a new driver coming up that introduces ich9 support without breaking 
(the old e1000) support for all other devices. This is why we want to drop a new 
version of the e1000 driver upstream instead, and put all newer devices in that 
driver.

For distro's not following kernel.org releases we have the perfect solution: A 
fully tested 7.5.5 driver on sourceforge that was extensively tested against 
RHEL5 for instance, but also a lot of other older kernels.

> What's the prognosis for the 7.5.5-series e1000 reorg going into
> netdev-2.6?

I sure hope to get it out before 2.6.23 merge window close... But anything can 
unfortunately happen.


Auke


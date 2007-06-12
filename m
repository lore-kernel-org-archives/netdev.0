From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Tue, 12 Jun 2007 19:00:17 -0400
Message-ID: <466F2581.2080808@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59180 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbXFLXA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 19:00:28 -0400
In-Reply-To: <20070611181429.GA4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
>> On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
>>> On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
>>>> On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
>>>>> The major bug fixes are: 
>>>> I realise it's late, but shouldn't "major bugfixes" be going into 22 ?
>>> Yeah, I suppose, I admit I've lost track of the process. 
>> You need to order your bug fixes first in the queue. 
> 
> OK, here are the patches, re-ordered. There is a different number
> than last time, as I threw out one, merged one, and got cold feet
> on a third one.  They still pass the tests.
> 
> The first five patches focus on three serious bugs, fixing crashes or
> hangs.
> 
> -- patch 1 -- kernel crash when ifdown while receiving packets.
> -- patch 2,3,4 -- device driver deadlocks on "RX ram full" mesgs.
>                   (kernel stays up, ifdown/up clear the problem).
> -- patch 5 -- misconfigured TX interrupts results in 3x-4x per
>               degradation for small packets.
> 
> -- patch 6 -- rx stats may be mangled
> -- patch 7 -- hw checksum sometimes breaks ipv6 operation
> 
> -- patches 8-15 -- misc tweaks, and documentation.
> 
> 
> I re-ran my stress tests with patches 1-7 applied; they pass.

This is a bit frustrating, because this includes many patches that you 
ALREADY told me to queue for 2.6.23, which I did, in 
netdev-2.6.git#upstream.

Should I just drop all spidernet patches and start over?

	Jeff




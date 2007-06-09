From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 20:17:33 -0400
Message-ID: <1181348253.4056.6.camel@localhost>
References: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com>
	 <1181218576.4064.40.camel@localhost>  <46699192.6010404@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.226]:55680 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030974AbXFIARh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 20:17:37 -0400
Received: by qb-out-0506.google.com with SMTP id z8so1168089qbc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 17:17:36 -0700 (PDT)
In-Reply-To: <46699192.6010404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 10:27 -0700, Rick Jones wrote:

[..]

> you cannot take the netperf service demand directly - each netperf is 
> calculating assuming that it is the only thing running on the system. 
> It then ass-u-me-s that the CPU util it measured was all for its work. 
> This means the service demand figure will be quite higher than it really is.
> 
> So, for aggregate tests using netperf2, one has to calculate service 
> demand by hand.  Sum the throughput as KB/s, convert the CPU util and 
> number of CPUs to a microseconds of CPU consumed per second and divide 
> to get microseconds per KB for the aggregate.

>From what you are saying above seems to me that for more than one proc
it is safe to just run netperf4 instead of netperf2?

It also seems reasonable to set up large socket buffers on the receiver.

cheers,
jamal




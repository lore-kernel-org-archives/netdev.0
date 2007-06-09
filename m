From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 17:40:16 -0700
Message-ID: <4669F6F0.9030303@hp.com>
References: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com>	<1181218576.4064.40.camel@localhost>  <46699192.6010404@hp.com> <1181348253.4056.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:50479 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762946AbXFIAk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 20:40:28 -0400
In-Reply-To: <1181348253.4056.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-08-06 at 10:27 -0700, Rick Jones wrote:
> 
> [..]
> 
> 
>>you cannot take the netperf service demand directly - each netperf is 
>>calculating assuming that it is the only thing running on the system. 
>>It then ass-u-me-s that the CPU util it measured was all for its work. 
>>This means the service demand figure will be quite higher than it really is.
>>
>>So, for aggregate tests using netperf2, one has to calculate service 
>>demand by hand.  Sum the throughput as KB/s, convert the CPU util and 
>>number of CPUs to a microseconds of CPU consumed per second and divide 
>>to get microseconds per KB for the aggregate.
> 
> 
> From what you are saying above seems to me that for more than one proc
> it is safe to just run netperf4 instead of netperf2?

Well, it is easier to be safe on aggregates with netperf4 than netperf2 
although at present it is more difficult to run netperf4 than netperf2


> It also seems reasonable to set up large socket buffers on the receiver.

For bulk transfers I often do.

rick

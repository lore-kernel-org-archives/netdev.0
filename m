From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net] net: rename and move busy poll mib counter
Date: Tue, 06 Aug 2013 13:23:06 +0300
Message-ID: <5200CE8A.1090707@linux.intel.com>
References: <20130806095207.5887.2196.stgit@ladj378.jer.intel.com> <1375784088.4457.74.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43186 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414Ab3HFKXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 06:23:24 -0400
In-Reply-To: <1375784088.4457.74.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2013 13:14, Eric Dumazet wrote:
> On Tue, 2013-08-06 at 12:52 +0300, Eliezer Tamir wrote:
>> Move the low latency mib counter to the ip section.
>> Rename it from low latency to busy poll.
>>
>> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
> 
> Well, it should not be part of IP mib, but a socket one (not existing so
> far)
> 
> Linux MIB already contains few non TCP counters :
> 
> LINUX_MIB_ARPFILTER
> LINUX_MIB_IPRPFILTER
> 
> Its mostly populated by TCP counters, sure.

So, just rename it to busy poll?
Or maybe just drop the whole patch?

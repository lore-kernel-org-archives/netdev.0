From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add additional lock to qdisc to increase
 throughput
Date: Wed, 02 Jun 2010 05:10:19 -0700 (PDT)
Message-ID: <20100602.051019.180420492.davem@davemloft.net>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<1274454480.2439.418.camel@edumazet-laptop>
	<80769D7B14936844A23C0C43D9FBCF0F256284B068@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211Ab0FBMKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:10:10 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F256284B068@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Fri, 21 May 2010 13:04:20 -0700

> Eric Dumazet wrote:
>> Tests with following script gave a boost from ~50.000 pps to ~600.000
>> pps on a dual quad core machine (E5450 @3.00GHz), tg3 driver.
>> (A single netperf flow can reach ~800.000 pps on this platform)
>> 
>> for j in `seq 0 3`; do
>>   for i in `seq 0 7`; do
>>     netperf -H 192.168.0.1 -t UDP_STREAM -l 60 -N -T $i -- -m 6 &
>>   done
>> done
> 
> Running the same script with your patch my results went from 200Kpps to 1.2Mpps on a dual Xeon 5570.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks guys.

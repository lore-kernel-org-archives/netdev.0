From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 27 Apr 2006 16:53:25 -0700
Message-ID: <44515975.3090109@hp.com>
References: <20060420213305.GK26746@pb15.lixom.net>	<20060420.172742.132879746.davem@davemloft.net>	<44482EB5.9030605@hp.com>	<20060420.181302.98895633.davem@davemloft.net>	<4449127A.8050404@hp.com> <41b516cb0604271649o31315086ma1c82b824da263e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, olof@lixom.net,
	andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:31931 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751769AbWD0Xx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 19:53:27 -0400
To: chris.leech@gmail.com
In-Reply-To: <41b516cb0604271649o31315086ma1c82b824da263e7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech wrote:
>>Netperf2 TOT now accesses the buffer that was just recv()'d rather than
>>the one that is about to be recv()'d.
> 
> 
> We've posted netperf2 results with I/OAT enabled/disabled and the data
> access option on/off at
> http://kernel.org/pub/linux/kernel/people/grover/ioat/netperf-icb-1.5-postscaling-both.pdf
> 

calling it netperf data verification is a quite overstated - all netperf 
does is read from or write to the buffer.  there is no check of data 
integrity or anything

rick jones

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Fri, 21 Apr 2006 10:12:26 -0700
Message-ID: <4449127A.8050404@hp.com>
References: <20060420213305.GK26746@pb15.lixom.net>	<20060420.172742.132879746.davem@davemloft.net>	<44482EB5.9030605@hp.com> <20060420.181302.98895633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:15529 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1750905AbWDURMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 13:12:30 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.181302.98895633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 20 Apr 2006 18:00:37 -0700
> 
> 
>>Actually, that brings-up a question - presently, and for reasons that 
>>are lost to me in the mists of time - netperf will "access" the buffer 
>>before it calls recv().  I'm wondering if that should be changed to an 
>>access of the buffer after it calls recv()?
> 
> 
> Yes, that's what it should do, as this is whan a real
> application would do.

Netperf2 TOT now accesses the buffer that was just recv()'d rather than 
the one that is about to be recv()'d.

rick jones

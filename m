From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] fix up sysctl_tcp_mem initialization
Date: Wed, 15 Nov 2006 12:46:00 -0500
Message-ID: <455B5258.5090504@psc.edu>
References: <455A20BD.6010508@psc.edu> <20061114.203118.35665382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:32201 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1030736AbWKORqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 12:46:05 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061114.203118.35665382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> However, I wonder if we want to set this differently than the way this 
>> patch does it.  Depending on how far off the memory size is from a power 
>> of two (exactly equal to a power of two is the worst case), and if total 
>> memory <128M, it can be substantially less than 3/4.
> 
> Longer term, yes, probably a better way exists.
> 
> So you concern is that when we round to a power of 2 like we do
> now, we often mis-shoot?

I'm not that concerned about it, but basically yes, there are big (x2) 
jumps on power-of-two memory size boundaries.  There's also a bigger 
(x8) discontinuity at 128k pages.  It could be smoother.

   -John

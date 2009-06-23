From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Use correct data types for ICMPv6 type and code
Date: Tue, 23 Jun 2009 04:31:20 -0700 (PDT)
Message-ID: <20090623.043120.267458548.davem@davemloft.net>
References: <4A39BE00.1050506@hp.com>
	<20090618.002632.18400816.davem@davemloft.net>
	<4A3FAF66.4060607@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754308AbZFWLbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 07:31:15 -0400
In-Reply-To: <4A3FAF66.4060607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 22 Jun 2009 12:20:54 -0400

> David Miller wrote:
>> From: Brian Haley <brian.haley@hp.com>
>> Date: Thu, 18 Jun 2009 00:09:36 -0400
>> 
>>> "type" is a u8 too, but both seem to be passed as int's everywhere (rawv6,
>>> tcp, sctp and dccp), and in the err_handler() func pointer in the inet6_protocol
>>> struct.  I can try and cook something up in the next few days that changes
>>> it all to u8's.
>> 
>> Feel free, thanks a lot.
> 
> I compile tested and made sure I could ping and get unreachables back up
> the TCP stack.  Also, applying Roel's original patch on top of this
> generated the expected compiler warning since it's always >= zero.
> 
> 
> Change all the code that deals directly with ICMPv6 type and code values
> to use u8 instead of a signed int as that's the actual data type.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Thanks a lot for doing this work Brian, applied!

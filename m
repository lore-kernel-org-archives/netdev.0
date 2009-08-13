From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 16:31:33 -0700 (PDT)
Message-ID: <20090813.163133.199571497.davem@davemloft.net>
References: <1250195675.28285.128.camel@Joe-Laptop.home>
	<457D0D34-041E-43AE-BE31-241A19AA08B4@oracle.com>
	<1250198022.28285.133.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, brian.haley@hp.com, jens@mcbone.net,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58769
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755673AbZHMXbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:31:22 -0400
In-Reply-To: <1250198022.28285.133.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 13 Aug 2009 14:13:42 -0700

> On Thu, 2009-08-13 at 17:02 -0400, Chuck Lever wrote:
>> [ I would think user space in general should be using inet_pton(3)  
>> everywhere for such interfaces, so the format of these addresses  
>> wouldn't matter so much.  Probably impossible at this point. ]
> 
> David Miller is authoritative here.

In the final analysis, the risk is just too high to break
userspace.  So let's play conservative here and not change
the output for currently user visible stuff.

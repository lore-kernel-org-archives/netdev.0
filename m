From: Ben Greear <greearb@candelatech.com>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 15:37:45 -0700
Message-ID: <46EB0D39.4030609@candelatech.com>
References: <46DDDFFA.6090705@candelatech.com>	<20070914.131225.78720330.davem@davemloft.net>	<46EB071B.9070308@candelatech.com> <20070914.152912.74747426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34434 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756661AbXINWhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 18:37:50 -0400
In-Reply-To: <20070914.152912.74747426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> Instead of nit-picking, can you instead try the patch and let me
> know if it makes things work for you?

I don't mean to complain, just trying to make sure that you
had thought about the length and were happy with how it works
before I try to get the man page changed.

I will try the patch, but it will probably not be until Monday.
The existing code actually can be made to work by passing in
a 4+ byte string and setting the first byte to zero, and as
far as I can see, that remains the same with the new patch.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


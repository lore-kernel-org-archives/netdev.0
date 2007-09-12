From: David Miller <davem@davemloft.net>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Wed, 12 Sep 2007 08:08:32 -0700 (PDT)
Message-ID: <20070912.080832.52182952.davem@davemloft.net>
References: <46DDDFFA.6090705@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:48899
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965835AbXILPIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 11:08:37 -0400
In-Reply-To: <46DDDFFA.6090705@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 04 Sep 2007 15:45:14 -0700

> According to the comment in the net/core/sock.c code (in 2.6.20), I should be able to pass a zero
> optlen to the setsockopt method for SO_BINDTODEVICE:
 ...
> 
> However, earlier in that method it returns -EINVAL if optlen is < sizeof(int).
> 
> The man page has comments similar to that in the code above.

Yes, the comment definitely does not match the code and
should be fixed one way or the other.

I'll do some code history research to try and figure out
if this optlen==0 case ever worked properly.

Thanks.

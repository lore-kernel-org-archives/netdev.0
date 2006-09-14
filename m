From: David Miller <davem@davemloft.net>
Subject: Re: ipip and ip_gre encapsulation bugs
Date: Wed, 13 Sep 2006 21:03:22 -0700 (PDT)
Message-ID: <20060913.210322.78723655.davem@davemloft.net>
References: <E1GNBTO-0001v7-Pb@ZenIV.linux.org.uk>
	<E1GNf14-0004dW-00@gondolin.me.apana.org.au>
	<20060914011637.GH29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, torvalds@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34745
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751283AbWINECa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 00:02:30 -0400
To: viro@ftp.linux.org.uk
In-Reply-To: <20060914011637.GH29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Thu, 14 Sep 2006 02:16:37 +0100

> OK, after rereading the RFC...  Pointer field is one octet, indeed.
> Avoiding all swapping will be tough - icmp_send() takes 32bit argument,
> net-endian.

Thanks for the fix Al, but did you notice that this code is totally
unused?  It's a code block commented out by a large ifdef, such that
the code block is never enabled and serves as example code we
could use if some limitations in the current internet did not
exist. :-)

But thanks anyways, I'll queue this up for 2.6.19

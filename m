From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv4: don't call upper-layer disconnect function if not
 connected
Date: Wed, 02 Aug 2006 12:04:22 -0400
Message-ID: <44D0CD06.3020201@hp.com>
References: <44CFB026.7050907@hp.com> <20060801.150753.78709843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:28845 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932083AbWHBQEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 12:04:25 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.150753.78709843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The socket could have been bind()'d to, in which case it will
> not move to connected state and we still need to invoke
> the disconnect methods such as udp_disconnect() to clear out
> that binding.

Ok.

> You seem to be groveling in random areas of the ipv4 and ipv6 stack,
> what are you working on?

Was looking into a customer-reported memory leak that seemed to be in 
this code path.  It wasn't, but this tweak seemed sane at the time.

-Brian

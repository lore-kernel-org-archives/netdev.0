From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
 socket attached to the skb
Date: Wed, 01 Oct 2008 07:50:40 -0700 (PDT)
Message-ID: <20081001.075040.135314845.davem@davemloft.net>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.69772.stgit@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001142431.4893.69772.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 16:24:31 +0200

> Use the socket cached in the TPROXY target if it's present.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Ok, this starts to get into controversial territory.
:-)

At the very least I think:

1) We should do this unconditionally, and even put
   a "unlikely" there in the test.

2) Actually, the whole operation belongs in a generic
   net/sock.h helper function, and this includes the
   leading if() test.

In the resubmitted patch you can include both UDP
and TCP and the change adding the generic helper all
at once.

Thanks.

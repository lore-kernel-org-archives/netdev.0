From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [-mm PATCH] signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 12:16:28 -0700 (PDT)
Message-ID: <20050615.121628.112622743.davem@davemloft.net>
References: <Pine.LNX.4.62.0506152101350.3842@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        waltje@uWalt.NL.Mugnet.ORG.sgi.com, ross.biro@gmail.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: juhl-lkml@dif.dk
In-Reply-To: <Pine.LNX.4.62.0506152101350.3842@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm not merging this thing, at least no all at once.

"size_t" vs. "unsigned int" vs. "int" length comparisons are where all
the security problems come from in the protocol stack

Therefore you should make a seperate patch for each type
change you make and explain why it doesn't add some regression
in terms of signedness issues.

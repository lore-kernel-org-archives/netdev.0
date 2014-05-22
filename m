From: Horia Geanta <horia.geanta@freescale.com>
Subject: [RFC ipsec-next] Non-standard sha256 ICV truncation size
Date: Thu, 22 May 2014 18:10:36 +0300
Message-ID: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lei Xu <Lei.Xu@freescale.com>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am sending this patch as RFC, since the change is likely to create
interoperability issues.
I'd like to get some comments on what should be the correct approach in this
standard vs. de facto setup.

Note that an older commit (which is no longer in git's history, but can be found
here https://archive.org/details/git-history-of-linux) changed truncated ICV size
from 128bit to 96bit:

commit 627d1054055f465603bcfb7ef5c9adc5db9b2a53
Author: Michal Ludvig <michal@logix.cz>
Date:   Fri Jan 9 04:55:59 2004 -0800

    [XFRM]: SHA2-256 should be truncated to 96 bits, not 128.

It seems that initially the sha256 ICV was truncated to 128 bits, but later
changed to 96 bits due to interoperability issues - see comment here:
http://oss.sgi.com/archives/netdev/2004-01/msg00824.html

Note that commit above is from 2004, long before RFC4868 was released (2007).

Thanks,
Horia

Lei Xu (1):
  xfrm: make sha256 icv truncation length RFC-compliant

 net/xfrm/xfrm_algo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.8.3.1

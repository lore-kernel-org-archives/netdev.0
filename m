From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Sat, 30 Sep 2006 22:25:49 +0300
Message-ID: <200609302225.49760.ismail@pardus.org.tr>
References: <200609302223.47627.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: axboe@suse.de, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:28295 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1751459AbWI3TZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 15:25:24 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200609302223.47627.ismail@pardus.org.tr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 30 September 2006 22:23, you wrote:
> Hi,
>
> With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE
> changed behaviour so it returns false when the node is empty as expected.
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
make it : so it returns true when the node is empty as expected

/ismail
-- 
They that can give up essential liberty to obtain a little temporary safety 
deserve neither liberty nor safety.
-- Benjamin Franklin

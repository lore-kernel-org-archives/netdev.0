From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ftmac100: use resource_size()
Date: Fri, 18 Mar 2011 21:53:13 -0700 (PDT)
Message-ID: <20110318.215313.149843288.davem@davemloft.net>
References: <20110319043915.GB2008@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ratbert@faraday-tech.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350Ab1CSEwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 00:52:35 -0400
In-Reply-To: <20110319043915.GB2008@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 19 Mar 2011 07:39:15 +0300

> The calculation is off-by-one.  It should be "end - start + 1".  This
> patch fixes it to use resource_size() instead.  Oddly, the code already
> uses resource size correctly a couple lines earlier when it calls
> request_mem_region() for this memory.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks for fixing this Dan.

From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Tue, 7 Sep 2010 13:31:15 +0200
Message-ID: <20100907113115.GB5718@bicker>
References: <20100906122344.GA2764@bicker> <4C85FC02.3040804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39368 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab0IGLgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 07:36:40 -0400
Content-Disposition: inline
In-Reply-To: <4C85FC02.3040804@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 07, 2010 at 04:46:58PM +0800, Shan Wei wrote:
> Dan Carpenter wrote, at 09/06/2010 08:26 PM:
> > +	    &new_addr->transports != &new_asoc->peer.transport_addr_list) {
> 
> why did you add this check?
> 

That's the check which tells us if we broke out of the loop or if we
came to the end of the list.

As I explained before, the only way that the check matters is if the
list is empty.  With the current code I do not think we ever call this
function with an empty list, so that check is not needed.  But the code
could change I suppose and it doesn't hurt to be cautious.  On the other
hand, I'm fine with removing the check as well.

regards,
dan carpenter

> 
> -- 
> Best Regards
> -----
> Shan Wei

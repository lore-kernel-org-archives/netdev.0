From: David Miller <davem@davemloft.net>
Subject: Re: simplify microsecond rtt sampling
Date: Thu, 28 Sep 2006 14:49:14 -0700 (PDT)
Message-ID: <20060928.144914.56053619.davem@davemloft.net>
References: <451BC184.1000707@psc.edu>
	<451BC460.8080902@psc.edu>
	<20060928093650.179dab92@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44936
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932069AbWI1VtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:49:11 -0400
To: shemminger@osdl.org
In-Reply-To: <20060928093650.179dab92@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 28 Sep 2006 09:36:50 -0700

> On Thu, 28 Sep 2006 13:47:28 +0100
> John Heffner <jheffner@psc.edu> wrote:
> 
> > Sigh.  Here's one that's not corrupted.  And for the record:
> > 
> > 
> > This changes the microsecond RTT sampling so that samples are taken in 
> > the same way that RTT samples are taken for the RTO calculator: on the 
> > last segment acknowledged, and only when the segment hasn't been 
> > retransmitted.
> > 
> > 
> > Signed-off-by: John Heffner <jheffner@psc.edu>
> 
> Looks ok. I wish skbuff timestamp was converted to ktime.

It looks good to me too, applied.

Since this is really a bug fix, I'm goint to push this into
-stable as well.

Thanks a lot.

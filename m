From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: simplify microsecond rtt sampling
Date: Thu, 28 Sep 2006 09:36:50 -0700
Message-ID: <20060928093650.179dab92@freekitty>
References: <451A5EC9.6090001@psc.edu>
	<451A9519.6000504@psc.edu>
	<451BC184.1000707@psc.edu>
	<451BC460.8080902@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23754 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751955AbWI1RRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 13:17:52 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <451BC460.8080902@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 13:47:28 +0100
John Heffner <jheffner@psc.edu> wrote:

> Sigh.  Here's one that's not corrupted.  And for the record:
> 
> 
> This changes the microsecond RTT sampling so that samples are taken in 
> the same way that RTT samples are taken for the RTO calculator: on the 
> last segment acknowledged, and only when the segment hasn't been 
> retransmitted.
> 
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Looks ok. I wish skbuff timestamp was converted to ktime.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT v2] sh_eth: fix kernel oops in skb_put()
Date: Fri, 30 Oct 2015 18:02:54 +0900 (KST)
Message-ID: <20151030.180254.1737762744569865912.davem@davemloft.net>
References: <2611049.bTOQ0T0Nsl@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yashi@atmark-techno.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2611049.bTOQ0T0Nsl@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 25 Oct 2015 01:42:33 +0300

> In a low memory situation the following kernel oops occurs:
 ...
> This is because netdev_alloc_skb() fails and 'mdp->rx_skbuff[entry]' is left
> NULL but sh_eth_rx() later uses it without checking. Add such check...
> 
> Reported-by: Yasushi SHOJI <yashi@atmark-techno.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

This seems to need more investigation and work, therefore I am
not applying this at this time.

When a final version is available (or even if this one is deemed
appropriate as-is) please resubmit it withut RFT in the Subject.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: MIB "ipInHdrErrors" error
Date: Mon, 12 Jun 2006 13:10:15 -0700 (PDT)
Message-ID: <20060612.131015.99456225.davem@davemloft.net>
References: <1150102163.2974.9.camel@L-tech>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48534
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932215AbWFLUKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 16:10:06 -0400
To: weid@nanjing-fnst.com
In-Reply-To: <1150102163.2974.9.camel@L-tech>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Dong <weid@nanjing-fnst.com>
Date: Mon, 12 Jun 2006 16:49:23 +0800

> On Mon, 2006-06-12 at 15:24 +0800, Wei Dong wrote:
> > > Also, when kernel receives an IP packet and need to forward, but
> > > TTL=1 or TTL=0, kernel just sends an ICMP packet to inform the
> > > sender TTL count exceeded, and doesn't increase this counter.
> > 
> > This part of your change seems correct, please just resubmit
> > this part.
> The following is the latest patch for MIB ipIHdrErrors. 

Patch applied, thanks a lot.

From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Tue, 27 Feb 2007 17:29:34 +0100
Message-ID: <45E45C6E.3000504@myri.com>
References: <20070225004423.20903.17036.stgit@localhost.localdomain>	 <20070226051304.GA13626@infradead.org>	 <1172585835.11870.13.camel@stevo-desktop>  <45E445D2.2090900@garzik.org> <1172588246.11870.24.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, divy@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2001 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750829AbXB0Qcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 11:32:50 -0500
In-Reply-To: <1172588246.11870.24.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> You're right.  But cxgb3 has it now in the driver (tested and working).
> Shouldn't it be pulled in?  When the network stack design gets done
> (which could take a few releases to finalize), all the drivers can be
> updated to use it.  It doesn't seem reasonable to allow some drivers to
> support LRO and others to not support it...
>   

I have to agree with Steve here. We have been requesting the inclusion
of myri10ge LRO for 5 months now (before 2.6.19). I could understand
that duplicating LRO code between s2io and myri10ge was not a good idea
at this point. But, I now see that Netxen got merged way later (in
2.6.20) but it got its LRO merged immediately. I guess the LRO is
already duplicated between s2io and netxen then. It does not look fair
to me at all.

Thank you for understanding our concerns.
Brice


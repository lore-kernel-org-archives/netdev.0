From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 10:43:24 +0400
Message-ID: <20080708064324.GA11776@2ka.mipt.ru>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net> <20080708045443.GA7726@2ka.mipt.ru> <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36264 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbYGHGpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 02:45:38 -0400
Content-Disposition: inline
In-Reply-To: <adar6a4x510.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2008 at 11:29:31PM -0700, Roland Dreier (rdreier@cisco.com) wrote:
> nuttcp -T30 -i1 ends up with:
> 
> 14465.0625 MB /  30.01 sec = 4043.6073 Mbps 82 %TX 2 %RX
> 
> while setting the window even to 128 KB with
> nuttcp -w128k -T30 -i1 ends up with:
> 
> 36416.8125 MB /  30.00 sec = 10182.8137 Mbps 90 %TX 96 %RX
> 
> so it's a factor of 2.5 with nuttcp.  I've never seen other apps behave
> like that -- for example NPtcp (netpipe) only gets slower when
> explicitly setting the window size.
> 
> Strange...

Maybe nuttcp by default sets very small socket buffer size?

-- 
	Evgeniy Polyakov

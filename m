From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Fri, 16 Nov 2012 21:47:42 +0000
Message-ID: <20121116214742.GH10831@casper.infradead.org>
References: <1352991680-12289-1-git-send-email-michele@acksyn.org>
 <20121116163922.GA9722@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47315 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2KPVrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 16:47:48 -0500
Content-Disposition: inline
In-Reply-To: <20121116163922.GA9722@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/12 at 11:39am, Neil Horman wrote:
> Yes, I think this is good, I still don't like the idea of having to do these via
> an ioctl, but I suppose it fits well enough.

I'm with you on this. I have started scribbling notes on paper for
a netlink based stats retriever. We should discuss this at some
point making sure we get everyone on board with interests in this
and solve this nice and clean for everyone to enjoy.

I guess the ioctl is the best we can do as long as we don't have
the above.

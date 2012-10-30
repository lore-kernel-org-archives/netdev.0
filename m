From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Tue, 30 Oct 2012 14:54:44 +0000
Message-ID: <20121030145444.GO13450@casper.infradead.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
 <20121029084143.GA17442@casper.infradead.org>
 <20121029113700.GA9332@hmsreliant.think-freely.org>
 <508EE586.9060907@gmail.com>
 <20121030111546.GA14013@hmsreliant.think-freely.org>
 <508FE256.9010205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56945 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933781Ab2J3Oyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 10:54:47 -0400
Content-Disposition: inline
In-Reply-To: <508FE256.9010205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/12 at 10:21am, Vlad Yasevich wrote:
> What if the message arrived across multiple transports?
> 
> Also, you can always see current rto, but that means that the
> application has to still poll for it with PEER_ADDR_INFO.  I think
> the idea, as Thomas pointed out, is to easily see what the max rto
> was.  I like that, but I don't like the fact that it's per
> association.   With that stat we really don't know which transport
> spiked.  So, it gives us a some useful information, but not really
> enough.
> 
> It might be a little more useful to keep track of the which
> transport has experienced the spike and then return info about it.
> Granted, we may be too late and the spike corrected itself already,
> but at least it will give the management application a little more
> information and allow admin to have a little more info to determine
> why the spike occurred.

Agreed and good point, a per transport max rto makes more sense.

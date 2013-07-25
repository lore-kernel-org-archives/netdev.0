From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] pktgen: Add UDPCSUM flag to support UDP
 checksums
Date: Thu, 25 Jul 2013 15:37:28 +0100
Message-ID: <20130725143728.GA15947@casper.infradead.org>
References: <8e168d7f8b1d82be3d33f1790f3bf435a0ba1390.1374753898.git.tgraf@suug.ch>
 <51F12FCD.8080604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42218 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884Ab3GYOha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 10:37:30 -0400
Content-Disposition: inline
In-Reply-To: <51F12FCD.8080604@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/13 at 07:01am, Ben Greear wrote:
> >+		else if (strcmp(f, "UDPCSUM") == 0)
> >+			pkt_dev->flags |= F_UDPCSUM;
> >+
> 
> Looks like we need a way to turn it back off again too??

Yes, good point. Although you would typically want to start
with fresh devices to make sure you have a default set of
flags set.

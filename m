From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add SO_MAX_DGRAM_QLEN for AF_UNIX SOCK_DGRAM
 sockets
Date: Tue, 03 Mar 2015 13:59:15 -0500 (EST)
Message-ID: <20150303.135915.946638858654752454.davem@davemloft.net>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
	<20150302.213807.367185406305242762.davem@davemloft.net>
	<0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@mindstab.net, edumazet@google.com,
	hannes@stressinduktion.org, linux-api@vger.kernel.org
To: christian@iwakd.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbbCCS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 13:59:18 -0500
In-Reply-To: <0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Seiler <christian@iwakd.de>
Date: Tue, 03 Mar 2015 10:04:10 +0100

>  - More importantly, timestamps of messages can't be faked at all. So
>    in the example of a socket used for syslog purposes, all the
>    timestamps on the messages queued would be wrong.

You can timestamp in the application and put that into your protocol
for sending the syslog messages.

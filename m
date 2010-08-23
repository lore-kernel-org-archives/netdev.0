From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 22:08:20 +0200
Message-ID: <20100823200820.GB5896@nuttenaction>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <20100823121449.29419771@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Tom Herbert <therbert@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38064 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753630Ab0HWUI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:08:29 -0400
Content-Disposition: inline
In-Reply-To: <20100823121449.29419771@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2010-08-23 12:14:49 [-0700]:

>If this is configurable (still not sure about having yet more
>TCP knobs). It should either be per-socket or a route metric so it can
>be controlled on a per-path basis.

BTW: quick ACK's are still configurable on the socket basis. But sometimes you
had no access to the code, the maintainer is busy or whatever ..

At least google inc is too busy to disable tcp quick ack's. And I think they will
save a lot of packets! Who make a bet? ;)

IP 192.168.1.35.45632 > 209.85.135.99.80: Flags [S], seq 4207702225, win 5840, options [mss 1460,sackOK,TS val 1669166 ecr 0,nop,wscale 7], length 0
IP 209.85.135.99.80 > 192.168.1.35.45632: Flags [S.], seq 263349349, ack 4207702226, win 5672, options [mss 1430,sackOK,TS val 397205192 ecr 1669166,nop,wscale 6], length 0
IP 192.168.1.35.45632 > 209.85.135.99.80: Flags [.], ack 1, win 46, options [nop,nop,TS val 1669168 ecr 397205192], length 0
IP 192.168.1.35.45632 > 209.85.135.99.80: Flags [P.], seq 1:925, ack 1, win 46, options [nop,nop,TS val 1669168 ecr 397205192], length 924
IP 209.85.135.99.80 > 192.168.1.35.45632: Flags [.], ack 925, win 118, options [nop,nop,TS val 397205208 ecr 1669168], length 0
IP 209.85.135.99.80 > 192.168.1.35.45632: Flags [P.], seq 1:510, ack 925, win 118, options [nop,nop,TS val 397205221 ecr 1669168], length 509

Hagen



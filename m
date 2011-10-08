From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bridge: Have tx_bytes count headers like rx_bytes.
Date: Sat, 08 Oct 2011 01:14:46 +0100
Message-ID: <1318032886.2771.149.camel@bwh-desktop>
References: <1318020461-14494-1-git-send-email-ashishsharma@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpa@google.com
To: Ashish Sharma <ashishsharma@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19227 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab1JHAOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 20:14:50 -0400
In-Reply-To: <1318020461-14494-1-git-send-email-ashishsharma@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 13:47 -0700, Ashish Sharma wrote:
> Since rx_bytes accounting does not include Ethernet Headers in
> br_input.c, excluding ETH_HLEN on the transmit path for consistent
> measurement of packet length on both the Tx and Rx chains.
[...]

I think the TX path is correct in this regard, and the RX path should be
changed to include header length.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

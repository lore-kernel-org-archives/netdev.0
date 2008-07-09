From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] TCP: Add seq and ack numbers to TCP_INFO
Date: Wed, 9 Jul 2008 10:49:34 -0700
Message-ID: <20080709104934.390cd81b@speedy>
References: <396556a20805301217k293e5718h6bbf02bfe069003@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44394 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194AbYGIRtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 13:49:36 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069003@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jul 2008 10:23:43 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> TCP: Add seq and ack numbers to TCP_INFO
> 
> No ABI breakage: Userspace specifies the size of the structure that they're
> expecting, and the new fields are at the end, so existing code should function
> just fine as we'll truncate the new struct tcp_info to fit.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Of what possible use is this to an application? I worry that applications would
come to expect or use certain characteristics of the network and TCP which
would be broken by later changes.

From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: setsockopt(IPIPPROTO_IPV6,IPV6_MINHOPCOUNT)
 forgot to set return value
Date: Sun, 11 Nov 2012 16:20:30 -0800
Message-ID: <20121111162030.4debc624@nehalam.linuxnetplumber.net>
References: <20121111055234.GA28043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35638 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab2KLAVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2012 19:21:31 -0500
In-Reply-To: <20121111055234.GA28043@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wonder if this ever worked? The patch should go
to stable as well.

The original coding style was prone to these kind of errors
because of the use of "goto e_inval" to do the unlock, and fall through
is prone to these kind of errors.

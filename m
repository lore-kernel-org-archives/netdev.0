From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: change gre_parse_header to return the
 header length
Date: Wed, 04 May 2016 12:45:26 -0400 (EDT)
Message-ID: <20160504.124526.864764985279452152.davem@davemloft.net>
References: <3627136025fbd767d70e2ce563aa5e37373c880a.1462280197.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbcEDQp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 12:45:29 -0400
In-Reply-To: <3627136025fbd767d70e2ce563aa5e37373c880a.1462280197.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  3 May 2016 15:00:21 +0200

> It's easier for gre_parse_header to return the header length instead of
> filing it into a parameter. That way, the callers that don't care about the
> header length can just check whether the returned value is lower than zero.
> 
> In gre_err, the tunnel header must not be pulled. See commit b7f8fe251e46
> ("gre: do not pull header in ICMP error processing") for details.
> 
> This patch reduces the conflict between the mentioned commit and commit
> 95f5c64c3c13 ("gre: Move utility functions to common headers").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.

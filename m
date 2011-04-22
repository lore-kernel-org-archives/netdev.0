From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: Re: [PATCH] netfilter/IPv6: fix DSCP mangle code
Date: Fri, 22 Apr 2011 16:29:22 +0900
Message-ID: <1303457362.9791.8.camel@nausicaa>
References: <1303455759.2023.39.camel@nausicaa>
	 <20110422.000838.193727308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:59026 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab1DVH3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 03:29:24 -0400
In-Reply-To: <20110422.000838.193727308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-22 at 00:08 -0700, David Miller wrote:
> From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Date: Fri, 22 Apr 2011 16:02:39 +0900
> 
> > The mask indicates the bits one wants to zero out, so it needs to be
> > inverted before applying to the original TOS field.
> > 
> > Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> > ---
> 
> Netfilter patches should be sent to the netfilter developer
> list, CC:'d

Thank you for the heads-up, David.

By the way, I have just sent one more patch that fixes what I think is
another netfilter bug. If everyone is ok with these two patches it would
be great if we could get them merged for the next -rc release (we hit
these bugs in our production systems).

Regards,
Fernando


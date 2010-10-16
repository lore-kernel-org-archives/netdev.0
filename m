From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v2)
Date: Fri, 15 Oct 2010 21:23:10 -0700
Message-ID: <20101015212310.47a74d86@nehalam>
References: <20101015224309.179898823@vyatta.com>
	<20101015224523.633775810@vyatta.com>
	<20101015171057.409db0f2@nehalam>
	<4CB8FBCE.3090401@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42725 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab0JPEXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Oct 2010 00:23:15 -0400
In-Reply-To: <4CB8FBCE.3090401@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Oct 2010 18:11:42 -0700
Dimitris Michailidis <dm@chelsio.com> wrote:

> Stephen Hemminger wrote:
> > Make functions only used in one file local.
> > Remove lots of dead code, relating to unsupported functions
> > in mainline driver like RSS, IPv6, and TCP offload.
> 
> Thanks, this looks OK.  One exception, cxgb4_get_tcp_stats was intended to 
> be used by the rdma driver.  I see that driver doesn't call it presently but 
> if you don't mind can we give Steve a few hours to tell us if he has any 
> imminent plans to use it.  If he doesn't offer to do something to use it for 
> .37 it goes.

The kernel source tree is not your development place holder tree.
At least #ifdef the code out for now.

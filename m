From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next] xfrm: add LINUX_MIB_XFRMACQUIREERROR
 statistic counter
Date: Thu, 6 Jun 2013 14:23:50 +0200
Message-ID: <20130606122350.GC3109@secunet.com>
References: <1370484954-30023-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58655 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932882Ab3FFMXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 08:23:54 -0400
Content-Disposition: inline
In-Reply-To: <1370484954-30023-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 06, 2013 at 10:15:54AM +0800, Fan Du wrote:
> When host ping its peer, ICMP echo request packet triggers IPsec
> policy, then host negotiates SA secret with its peer. After IKE
> installed SA for OUT direction, but before SA for IN direction
> installed, host get ICMP echo reply from its peer. At the time
> being, the SA state for IN direction could be XFRM_STATE_ACQ,
> then the received packet will be dropped after adding
> LINUX_MIB_XFRMINSTATEINVALID statistic.
> 
> Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
> scenario when SA in larval state is much clearer for user than
> LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
> bad.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied to ipsec-next.

Thanks!

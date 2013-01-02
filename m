From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: removes a superfluous check and add a
 statistic
Date: Wed, 2 Jan 2013 12:13:29 +0100
Message-ID: <20130102111329.GA1002@secunet.com>
References: <1356681988-7985-1-git-send-email-roy.qing.li@gmail.com>
 <20121228.152235.290256503144308680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38301 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab3ABLNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 06:13:32 -0500
Content-Disposition: inline
In-Reply-To: <20121228.152235.290256503144308680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 03:22:35PM -0800, David Miller wrote:
> From: roy.qing.li@gmail.com
> Date: Fri, 28 Dec 2012 16:06:28 +0800
> 
> > From: Li RongQing <roy.qing.li@gmail.com>
> > 
> > Remove the check if x->km.state equal to XFRM_STATE_VALID in
> > xfrm_state_check_expire(), which will be done before call
> > xfrm_state_check_expire().
> > 
> > add a LINUX_MIB_XFRMOUTSTATEINVALID statistic to record the
> > outbound error due to invalid xfrm state.
> > 
> > Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> 
> I'll let Steffen pick this up when he returns from his holiday
> break.

I'll take care of all the pending IPsec patches once I'm back
at office on monday.

Thanks for your patience.

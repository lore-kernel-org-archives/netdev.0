From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: removes a superfluous check and add a
 statistic
Date: Mon, 7 Jan 2013 13:51:35 +0100
Message-ID: <20130107125135.GR18940@secunet.com>
References: <1356681988-7985-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55256 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab3AGMvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 07:51:37 -0500
Content-Disposition: inline
In-Reply-To: <1356681988-7985-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2012 at 04:06:28PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Remove the check if x->km.state equal to XFRM_STATE_VALID in
> xfrm_state_check_expire(), which will be done before call
> xfrm_state_check_expire().
> 
> add a LINUX_MIB_XFRMOUTSTATEINVALID statistic to record the
> outbound error due to invalid xfrm state.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to ipsec-next,

Thanks!

From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3 net-next] bridge: cleanup netpoll code
Date: Thu, 25 Jul 2013 09:05:39 -0400
Message-ID: <20130725130539.GB19366@hmsreliant.think-freely.org>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37041 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab3GYNFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:05:47 -0400
Content-Disposition: inline
In-Reply-To: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 11:51:41AM -0700, Stephen Hemminger wrote:
> This started out with fixing a sparse warning, then I realized that
> the wrapper function br_netpoll_info could just be collapsed away
> by rolling it into the enable code.
> 
> Also, eliminate unnecessary goto's
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

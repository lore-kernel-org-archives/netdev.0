From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 22:20:07 +0200
Message-ID: <20130731202006.GE8027@netboy>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
 <20130731194523.GB900@radagast>
 <20130731200428.GD8027@netboy>
 <20130731200756.GA3737@radagast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-omap@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:60689 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab3GaUUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 16:20:20 -0400
Content-Disposition: inline
In-Reply-To: <20130731200756.GA3737@radagast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 11:07:56PM +0300, Felipe Balbi wrote:
> 
> what I'm saying is that we can give new IP revision a chance to work if
> they have no programming model differences (except for, perhaps, new
> features and different erratas).

But it also has a chance to fail when there are differences.
Comparing CPSW V1 with V2, it appears that TI likes to move the
registers around between versions. To me, this is reason enough to
make the driver defensive.

Thanks,
Richard

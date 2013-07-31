From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 22:34:06 +0200
Message-ID: <20130731203406.GF8027@netboy>
References: <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
 <20130731194523.GB900@radagast>
 <20130731200428.GD8027@netboy>
 <20130731200756.GA3737@radagast>
 <20130731202006.GE8027@netboy>
 <20130731202617.GB3737@radagast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-omap@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:64797 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab3GaUeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 16:34:18 -0400
Content-Disposition: inline
In-Reply-To: <20130731202617.GB3737@radagast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 11:26:17PM +0300, Felipe Balbi wrote:
> 
> oh well, we can go on and on with this. Unfortunately we (SW team) don't
> have control over the HW folks. We strongly suggest that they don't
> break SW compatibility, and that's starting to become true.
> 
> You can very well expect next version of CPSW to be SW compatible. If it
> isn't, then TI will send patches to add a new revision check and treat
> it well. We are the first ones to have access to new versions of all
> our IPs anyway.

Okay, so starting with V3 the registers probably won't be moving
around any more. But at the very least your patch should include
macros for the known V3 along with the default case.

Thanks,
Richard

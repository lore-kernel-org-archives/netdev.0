From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying
 device
Date: Wed, 26 Mar 2008 00:15:57 -0700 (PDT)
Message-ID: <20080326.001557.147425396.davem@davemloft.net>
References: <47E9E2C8.8070609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39728
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbYCZHP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:15:57 -0400
In-Reply-To: <47E9E2C8.8070609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 26 Mar 2008 06:44:40 +0100

> commit 23309e2679f45ffd6406a269310742a05eabfd99
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Mar 26 06:29:07 2008 +0100
> 
>     [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device
> 
>     Changing these flags requires to use dev_set_allmulti/dev_set_promiscuity
>     or dev_change_flags. Setting it directly causes two unwanted effects:
> 
>     - the next dev_change_flags call will notice a difference between
>       dev->gflags and the actual flags, enable promisc/allmulti
>       mode and incorrectly update dev->gflags
> 
>     - this keeps the underlying device in promisc/allmulti mode until
>       the VLAN device is deleted
> 
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied and I'll queue this up for -stable too.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: make function tables const
Date: Thu, 14 Apr 2011 21:55:24 -0700 (PDT)
Message-ID: <20110414.215524.104068954.davem@davemloft.net>
References: <20110414085012.3e45d7b4@nehalam>
	<1302799038.2853.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, shodgson@solarflare.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752661Ab1DOEz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 00:55:59 -0400
In-Reply-To: <1302799038.2853.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 14 Apr 2011 17:37:18 +0100

> On Thu, 2011-04-14 at 08:50 -0700, Stephen Hemminger wrote:
>> The phy, mac, and board information structures should be const.
> 
> efx_nic_type actually holds information and function pointers about
> different generations of the controller, not different boards.
> 
>> Since tables contain function pointer this improves security
>> (at least theoretically).
>> 
>> Compile tested only.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

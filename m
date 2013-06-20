From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Move MII out from under NET_CORE and
 hide it
Date: Wed, 19 Jun 2013 22:23:34 -0700 (PDT)
Message-ID: <20130619.222334.958758739338501268.davem@davemloft.net>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
	<1371522291.3495.63.camel@deadeye.wl.decadent.org.uk>
	<1371549722.2133.145.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3FTFXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:23:35 -0400
In-Reply-To: <1371549722.2133.145.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Jun 2013 03:02:02 -0700

> On Tue, 2013-06-18 at 03:24 +0100, Ben Hutchings wrote:
>> All drivers that select MII also need to select NET_CORE because MII
>> depends on it.  This is a bit ridiculous because NET_CORE is just a
>> menu option that doesn't enable any code by itself.
>> 
>> There is also no need for it to be a visible option, since its users
>> all select it.
>> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
 ...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

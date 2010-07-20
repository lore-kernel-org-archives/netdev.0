From: David Miller <davem@davemloft.net>
Subject: Re: With disable_ipv6 set to 1 on an interface, ff00:/8 and
 fe80::/64 are still added on device UP
Date: Tue, 20 Jul 2010 13:48:51 -0700 (PDT)
Message-ID: <20100720.134851.09735512.davem@davemloft.net>
References: <AANLkTinHkaL49MS9agf525GRhWXSWIvVmn-Qz33Hcg6Y@mail.gmail.com>
	<4C460856.5090701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshkelkar@gmail.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761324Ab0GTUsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:48:35 -0400
In-Reply-To: <4C460856.5090701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 20 Jul 2010 16:34:30 -0400

> I believe the easiest way to fix this is the following patch, can
> you please test it?
 ...
> If the interface has IPv6 disabled, don't add a multicast or
> link-local route since we won't be adding a link-local address.
> 
> Reported-by: Mahesh Kelkar <maheshkelkar@gmail.com>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

This looks good to me, let me know when it has been tested.

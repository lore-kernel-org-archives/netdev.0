From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 8139cp: reset BQL when ring tx ring cleared
Date: Sat, 11 May 2013 18:21:25 -0700 (PDT)
Message-ID: <20130511.182125.896338102769943216.davem@davemloft.net>
References: <20130511170923.52673453@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Woodhouse@intel.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088Ab3ELBV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 21:21:27 -0400
In-Reply-To: <20130511170923.52673453@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 11 May 2013 17:09:23 -0700

> While looking for other problem found this potential issue.
> When the transmit ring is cleaned out, the Byte Queue Limit values
> need to be reset.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

You neither compiled, nor tested this.

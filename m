From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/20] [PATCH] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Sun, 30 Jul 2006 18:20:46 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607301819500.26424@d.namei>
References: <11541658921982-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:17552 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750832AbWG3WUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:20:49 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <11541658921982-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Masahide NAKAMURA wrote:

> +config IPV6_MIP6
> +	bool "IPv6: Mobility (EXPERIMENTAL)"
> +	depends on IPV6 && EXPERIMENTAL
> +	select XFRM
> +	select XFRM_ADVANCED

Why 'select' here instead of 'depends on'?

The overall kernel config is getting very messed up because of all of 
these selects.


- James
-- 
James Morris
<jmorris@namei.org>

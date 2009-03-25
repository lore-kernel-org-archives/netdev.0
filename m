From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Fix bind conficts with v4-mapped addresses
Date: Tue, 24 Mar 2009 23:27:06 -0700 (PDT)
Message-ID: <20090324.232706.242706646.davem@davemloft.net>
References: <1237947891-26825-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbZCYG1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:27:18 -0400
In-Reply-To: <1237947891-26825-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 24 Mar 2009 22:24:47 -0400

> 
> This is an updated patch series to fix up bind() conflicts between v4-mapped
> and IPv6 addresses.
> 
> These patches correct the following problems:
>     1) Disallow binding of a v4-mapped address on a IPV6_V6ONLY socket.
>     2) Allow IPv4 wildcards to bind at the same time as a native IPv6 address.
>     3) Make v4-mapped bind()s consitant with IPv4 native binds.
>     4) Fix conflict resolutions between v4-mapped addresses, v4 addresses, and v6
>        addresses

All applied, thanks Vlad.

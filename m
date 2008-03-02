From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
 addresses
Date: Sun, 02 Mar 2008 21:39:02 +0900 (JST)
Message-ID: <20080302.213902.68664760.yoshfuji@linux-ipv6.org>
References: <20080221100842.GA24905@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jmtapio@verkkotelakka.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53612 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbYCBMiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 07:38:01 -0500
In-Reply-To: <20080221100842.GA24905@verkkotelakka.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080221100842.GA24905@verkkotelakka.net> (at Thu, 21 Feb 2008 12:08:42 +0200), Juha-Matti Tapio <jmtapio@verkkotelakka.net> says:

> Skip the prefix length matching in source address selection for
> orchid -> non-orchid addresses.
> 
> Overlay Routable Cryptographic Hash IDentifiers (RFC 4843,
> 2001:10::/28) are currenty not globally reachable. Without this
> check a host with an ORCHID address can end up preferring those over
> regular addresses when talking to other regular hosts in the 2001::/16
> range thus breaking non-orchid connections.
> 
> Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>

Is this really required?
I believe address labels (rule 6) should work, no?

--yoshfuji

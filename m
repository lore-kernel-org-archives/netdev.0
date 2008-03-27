From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1 of 5] IPv6: do not wrap around when the lifetime has
 expired
Date: Fri, 28 Mar 2008 03:25:39 +0900 (JST)
Message-ID: <20080328.032539.66693379.yoshfuji@linux-ipv6.org>
References: <patchbomb.1206305168@pirzuine>
	<dd125a7f86968371046d.1206305169@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55361 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbYC0SYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 14:24:10 -0400
In-Reply-To: <dd125a7f86968371046d.1206305169@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <dd125a7f86968371046d.1206305169@pirzuine> (at Sun, 23 Mar 2008 21:46:09 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: do not wrap around when the lifetime has expired
> 
> Instead of reporting overly large lifetimes to userspace,
> report a lifetime of 0 when a lifetime has expired.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

NAK.

(signed) lifetime < 0 means it has expired, but 0 does not mean
that the lifetime has expired, but it is being expired
(within 1 second).

--yoshfuji

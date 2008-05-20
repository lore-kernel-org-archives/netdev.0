From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for
 linklocal is completed.
Date: Tue, 20 May 2008 17:33:53 +0900 (JST)
Message-ID: <20080520.173353.128167700.yoshfuji@linux-ipv6.org>
References: <48324792.5070309@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: tabe@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43711 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613AbYETIdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 04:33:31 -0400
In-Reply-To: <48324792.5070309@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <48324792.5070309@miraclelinux.com> (at Tue, 20 May 2008 12:37:54 +0900), Toyo Abe <tabe@miraclelinux.com> says:

> This patch fixes the problem by deferring DAD initiation for global address until
> DAD for linklocal address is completed. Now the failed test scenarios noted above
> are all passed.

Why don't we just ignore RA until DAD for link-local
address has been successfully completed?

--yoshfuji


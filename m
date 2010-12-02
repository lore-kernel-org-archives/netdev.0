From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V2] ehea: Use the standard logging functions
Date: Thu, 02 Dec 2010 16:54:58 -0200
Message-ID: <4CF7EB82.5020609@linux.vnet.ibm.com>
References: <1290790908.11971.303.camel@Joe-Laptop> <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com> <1290814046.11971.320.camel@Joe-Laptop> <4CF52E7C.7010308@linux.vnet.ibm.com> <1291141124.18026.254.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:45807 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab0LBSzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 13:55:04 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id oB2IlDxF029887
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 16:47:13 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2Irc9T2486312
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 15:53:39 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2IslWv009210
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 16:54:47 -0200
In-Reply-To: <1291141124.18026.254.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2010 04:18 PM, Joe Perches wrote:
> Remove ehea_error, ehea_info and ehea_debug macros.
> Use pr_fmt, pr_<level>, netdev_<level>  and netif_<level>  as appropriate.
> Fix messages to use trailing "\n", some messages had an extra one
> as the old ehea_<level>  macros added a trailing "\n".
> Coalesced long format strings.
>
> Uncompiled/untested.
>
> Signed-off-by: Joe Perches<joe@perches.com>
Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>

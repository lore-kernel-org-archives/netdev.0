From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] add compat support for getsockopt (MCAST_MSFILTER)
Date: Mon, 28 Apr 2008 15:36:50 +0900 (JST)
Message-ID: <20080428.153650.57555735.yoshfuji@linux-ipv6.org>
References: <OFCC2BF571.D815BBAC-ON88257439.001DC6D6-88257439.001F49AD@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33829 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbYD1Ggv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 02:36:51 -0400
In-Reply-To: <OFCC2BF571.D815BBAC-ON88257439.001DC6D6-88257439.001F49AD@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFCC2BF571.D815BBAC-ON88257439.001DC6D6-88257439.001F49AD@us.ibm.com> (at Sun, 27 Apr 2008 23:41:51 -0600), David Stevens <dlstevens@us.ibm.com> says:

> This patch adds support for getsockopt for MCAST_MSFILTER for
> both IPv4 and IPv6. It depends on the previous setsockopt patch,
> and uses the same method. In addition, there are these cleanups
> included for the setsockopt patch:
> 
> 1) added missing "__user" for kgsr and kgf pointers
> 2) verify read for only GROUP_FILTER_SIZE(0). The group_filter
>         structure definition (via RFC) includes space for one source
>         in the source list array, but that source need not be present.
>         So, sizeof(group_filter) > GROUP_FILTER_SIZE(0). Fixed
>         the user read-check for minimum length to use the smaller size.
> 3) remove unneeded "&" for gf_slist addresses

IMHO, It's much better to split into 2 pathces - bug fixes and
getsockopt() support...

--yoshfuji

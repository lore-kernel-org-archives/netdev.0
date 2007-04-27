From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 source routing patch is still broken?
Date: Fri, 27 Apr 2007 18:36:35 +0900 (JST)
Message-ID: <20070427.183635.108797764.yoshfuji@linux-ipv6.org>
References: <20070426.153142.57441302.davem@davemloft.net>
	<46312E42.4070204@redhat.com>
	<20070427.020805.88703639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org, vsu@altlinux.ru,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33246 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbXD0Jgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 05:36:33 -0400
In-Reply-To: <20070427.020805.88703639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070427.020805.88703639.davem@davemloft.net> (at Fri, 27 Apr 2007 02:08:05 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> then the function proceeds to use the largest of
> 'accept_source_route' and 'idev->cnf.accept_source_route'
> for further checks.

Smallest:
        if (accept_source_route > idev->cnf.accept_source_route)
                accept_source_route = idev->cnf.accept_source_route;

--yoshufji

From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 source routing patch is still broken?
Date: Fri, 27 Apr 2007 02:41:16 -0700 (PDT)
Message-ID: <20070427.024116.74748059.davem@davemloft.net>
References: <46312E42.4070204@redhat.com>
	<20070427.020805.88703639.davem@davemloft.net>
	<20070427.183635.108797764.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org, vsu@altlinux.ru
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755522AbXD0JlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 05:41:07 -0400
In-Reply-To: <20070427.183635.108797764.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 27 Apr 2007 18:36:35 +0900 (JST)

> In article <20070427.020805.88703639.davem@davemloft.net> (at Fri, 27 Apr 2007 02:08:05 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > then the function proceeds to use the largest of
> > 'accept_source_route' and 'idev->cnf.accept_source_route'
> > for further checks.
> 
> Smallest:
>         if (accept_source_route > idev->cnf.accept_source_route)
>                 accept_source_route = idev->cnf.accept_source_route;

Correct, my mistake.

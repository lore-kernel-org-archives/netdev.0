From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Fri, 10 Aug 2007 11:14:20 +0900 (JST)
Message-ID: <20070810.111420.29442251.yoshfuji@linux-ipv6.org>
References: <m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
	<20070810.104710.28739250.yoshfuji@linux-ipv6.org>
	<20070809.184921.11594412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, adobriyan@sw.ru,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54246 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbXHJCNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 22:13:18 -0400
In-Reply-To: <20070809.184921.11594412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070809.184921.11594412.davem@davemloft.net> (at Thu, 09 Aug 2007 18:49:21 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Fri, 10 Aug 2007 10:47:10 +0900 (JST)
> 
> > I disagree.  It is bad to remove existing interface.
> > Ditto for other patches.
> 
> I think perhaps you misunderstand what Eric is doing.
> 
> sys_sysctl() isn't working properly for these cases and it is both a
> deprecated interface and not worth the pain of adding support
> in these cases.

Would you explain why it does not work properly
for those cases?

--yoshfuji

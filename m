From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Thu, 09 Aug 2007 18:49:21 -0700 (PDT)
Message-ID: <20070809.184921.11594412.davem@davemloft.net>
References: <m14pj89pmt.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
	<20070810.104710.28739250.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, adobriyan@sw.ru,
	netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757658AbXHJBtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 21:49:21 -0400
In-Reply-To: <20070810.104710.28739250.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 10 Aug 2007 10:47:10 +0900 (JST)

> I disagree.  It is bad to remove existing interface.
> Ditto for other patches.

I think perhaps you misunderstand what Eric is doing.

sys_sysctl() isn't working properly for these cases and it is both a
deprecated interface and not worth the pain of adding support
in these cases.

The fact that nobody complains that none of this stuff works
via sys_sysctl() to me proves that it is never used.

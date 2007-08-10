From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Fri, 10 Aug 2007 11:29:15 +0900 (JST)
Message-ID: <20070810.112915.63714468.yoshfuji@linux-ipv6.org>
References: <20070809.184921.11594412.davem@davemloft.net>
	<20070810.111420.29442251.yoshfuji@linux-ipv6.org>
	<m1odhg6sbv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, adobriyan@sw.ru,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54264 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbXHJC2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 22:28:14 -0400
In-Reply-To: <m1odhg6sbv.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <m1odhg6sbv.fsf@ebiederm.dsl.xmission.com> (at Thu, 09 Aug 2007 20:23:16 -0600), ebiederm@xmission.com (Eric W. Biederman) says:

> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> writes:
> 
> > Would you explain why it does not work properly
> > for those cases?
> 
> Mostly no appropriate strategy routine was setup to 
> report the data to the caller of sys_sysctl.

I assume that default strategy have been existing for it, no?!
Maybe, I do miss something...

--yoshfuji

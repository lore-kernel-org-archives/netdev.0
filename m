From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Thu, 09 Aug 2007 20:23:16 -0600
Message-ID: <m1odhg6sbv.fsf@ebiederm.dsl.xmission.com>
References: <m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
	<20070810.104710.28739250.yoshfuji@linux-ipv6.org>
	<20070809.184921.11594412.davem@davemloft.net>
	<20070810.111420.29442251.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, adobriyan@sw.ru, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?euc-jp?B?tcjGo7HRzMA=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:41155 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbXHJCYS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 22:24:18 -0400
In-Reply-To: <20070810.111420.29442251.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Fri, 10 Aug 2007 11:14:20 +0900 (JST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> =
writes:

> Would you explain why it does not work properly
> for those cases?

Mostly no appropriate strategy routine was setup to=20
report the data to the caller of sys_sysctl.

Eric
